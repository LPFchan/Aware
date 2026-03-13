//
//  MenuBarController.swift
//  Aware
//
//  Owns PresenceDetector and SleepAssertion, drives the polling loop,
//  and presents the menu bar via NSStatusItem and NSMenu.
//

import AppKit
import AVFoundation
import CoreGraphics

enum DetectionStatus: String {
    case faceDetected = "Face detected"
    case noFace = "No face"
    case disabled = "Disabled"
}

enum PollingInterval: Int, CaseIterable {
    case fifteen = 15
    case thirty = 30
    case sixty = 60
    case twoMin = 120
    case threeMin = 180
    case fiveMin = 300
    case tenMin = 600

    var displayName: String {
        rawValue >= 60 ? "\(rawValue / 60)m" : "\(rawValue)s"
    }
}

final class MenuBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let presenceDetector = PresenceDetector()
    private let sleepAssertion = SleepAssertion()

    private var pollingTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.aware.timer", qos: .userInitiated)

    private(set) var detectionStatus: DetectionStatus = .disabled {
        didSet { updateMenu() }
    }

    private let defaults = UserDefaults.standard
    private let enabledKey = "aware.enabled"
    private let intervalKey = "aware.pollingInterval"

    var isEnabled: Bool {
        get { defaults.bool(forKey: enabledKey) }
        set { defaults.set(newValue, forKey: enabledKey); onEnabledChanged() }
    }

    var pollingInterval: PollingInterval {
        get {
            let raw = defaults.integer(forKey: intervalKey)
            return PollingInterval(rawValue: raw) ?? .thirty
        }
        set { defaults.set(newValue.rawValue, forKey: intervalKey); restartPollingTimer() }
    }

    override init() {
        super.init()
        #if DEBUG
        debugLog("MenuBarController init started")
        #endif
        setupStatusItem()
        updateMenu()
        if isEnabled {
            startPolling()
        }
        #if DEBUG
        debugLog("MenuBarController init complete. Status item button exists: \(statusItem.button != nil)")
        #endif
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else {
            #if DEBUG
            debugLog("ERROR: statusItem.button is nil - status bar item will not be visible!")
            #endif
            return
        }
        let image = NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: "Aware")
        image?.isTemplate = true  // Ensures proper menu bar tinting
        image?.size = NSSize(width: NSStatusBar.system.thickness, height: NSStatusBar.system.thickness)
        button.image = image
        button.toolTip = "Aware - Click to open menu"
        statusItem.menu = buildMenu()
        statusItem.isVisible = true
        #if DEBUG
        debugLog("Status item configured. Image: \(image != nil), Menu: \(statusItem.menu != nil)")
        #endif
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let statusItem = NSMenuItem(
            title: "Status: \(detectionStatus.rawValue)",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        menu.addItem(NSMenuItem.separator())

        let enableItem = NSMenuItem(title: "Enable", action: #selector(toggleEnabled), keyEquivalent: "")
        enableItem.target = self
        enableItem.state = isEnabled ? .on : .off
        menu.addItem(enableItem)

        let intervalMenu = NSMenu()
        for interval in PollingInterval.allCases {
            let item = NSMenuItem(
                title: interval.displayName,
                action: #selector(selectPollingInterval(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = interval.rawValue
            item.state = pollingInterval == interval ? .on : .off
            intervalMenu.addItem(item)
        }
        let intervalParent = NSMenuItem(title: "Polling interval", action: nil, keyEquivalent: "")
        intervalParent.submenu = intervalMenu
        menu.addItem(intervalParent)

        menu.addItem(NSMenuItem.separator())

        #if DEBUG
        let debugItem = NSMenuItem(title: "Show Debug Window", action: #selector(showDebugWindow), keyEquivalent: "d")
        debugItem.target = self
        menu.addItem(debugItem)
        #endif

        let quitItem = NSMenuItem(title: "Quit Aware", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func updateMenu() {
        guard let menu = statusItem.menu else { return }
        let statusItem = menu.items.first!
        statusItem.title = "Status: \(detectionStatus.rawValue)"

        if let enableItem = menu.items.first(where: { $0.title == "Enable" }) {
            enableItem.state = isEnabled ? .on : .off
        }

        if let intervalParent = menu.items.first(where: { $0.title == "Polling interval" }),
           let submenu = intervalParent.submenu {
            for item in submenu.items {
                item.state = item.tag == pollingInterval.rawValue ? .on : .off
            }
        }
    }

    private func onEnabledChanged() {
        if isEnabled {
            startPolling()
        } else {
            stopPolling()
            sleepAssertion.release()
            detectionStatus = .disabled
        }
        updateMenu()
    }

    private func startPolling() {
        stopPolling()
        pollingTimer = DispatchSource.makeTimerSource(queue: timerQueue)
        pollingTimer?.schedule(deadline: .now(), repeating: .seconds(pollingInterval.rawValue))
        pollingTimer?.setEventHandler { [weak self] in
            self?.performDetection()
        }
        pollingTimer?.activate()
        performDetection()
    }

    private func stopPolling() {
        pollingTimer?.cancel()
        pollingTimer = nil
    }

    private func restartPollingTimer() {
        if isEnabled {
            startPolling()
        }
        updateMenu()
    }

    private func performDetection() {
        // Skip camera check when user has recent keyboard/mouse activity — assume present
        let keyIdle = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .keyDown)
        let mouseIdle = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .mouseMoved)
        let idleSeconds = min(keyIdle, mouseIdle)
        if idleSeconds < 30.0 {
            DispatchQueue.main.async { [weak self] in
                _ = self?.sleepAssertion.acquire()
                self?.detectionStatus = .faceDetected
            }
            return
        }

        presenceDetector.checkForPresence { [weak self] result in
            DispatchQueue.main.async {
                self?.handleDetectionResult(result)
            }
        }
    }

    private func handleDetectionResult(_ result: PresenceDetector.Result) {
        switch result {
        case .faceDetected:
            _ = sleepAssertion.acquire()
            detectionStatus = .faceDetected
        case .noFace:
            sleepAssertion.release()
            detectionStatus = .noFace
        case .cameraUnavailable, .permissionDenied:
            isEnabled = false
            if result == .permissionDenied {
                showCameraDeniedAlert()
            }
        }
    }

    private func showCameraDeniedAlert() {
        let alert = NSAlert()
        alert.messageText = "Camera Access Required"
        alert.informativeText = "Aware needs camera access to detect your presence. Please enable it in System Settings > Privacy & Security > Camera."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func toggleEnabled() {
        if isEnabled {
            isEnabled = false
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                isEnabled = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    DispatchQueue.main.async {
                        self?.isEnabled = granted
                    }
                }
            case .denied, .restricted:
                showCameraDeniedAlert()
            @unknown default:
                break
            }
        }
    }

    @objc private func selectPollingInterval(_ sender: NSMenuItem) {
        if let interval = PollingInterval(rawValue: sender.tag) {
            pollingInterval = interval
        }
    }

    @objc private func quit() {
        #if DEBUG
        debugLog("Quit requested")
        #endif
        NSApplication.shared.terminate(nil)
    }

    #if DEBUG
    private var debugWindow: NSWindow?

    @objc private func showDebugWindow() {
        if debugWindow != nil {
            debugWindow?.orderFrontRegardless()
            return
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Aware Debug"
        window.isReleasedWhenClosed = false
        window.center()
        window.level = .floating

        let text = """
        Aware is running.

        Status: \(detectionStatus.rawValue)
        Enabled: \(isEnabled)
        Polling: \(pollingInterval.rawValue)s

        The menu bar shows a person icon.
        Look at the top-right of your screen.
        """
        let label = NSTextField(labelWithString: text)
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.frame = NSRect(x: 20, y: 20, width: 280, height: 140)
        label.autoresizingMask = [.minYMargin, .minXMargin]
        window.contentView?.addSubview(label)
        window.contentView?.frame = NSRect(x: 0, y: 0, width: 320, height: 180)

        debugWindow = window
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    #endif
}

#if DEBUG
extension MenuBarController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) === debugWindow {
            debugWindow = nil
        }
    }
}
#endif

#if DEBUG
private func debugLog(_ message: String) {
    let formatted = "[Aware] \(message)"
    print(formatted)
    NSLog("%@", formatted)
}
#endif
