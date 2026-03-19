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
import ServiceManagement

enum DetectionStatus: String {
    case faceDetected = "Face detected"
    case noFace = "No face"
    case externalAssertion = "Kept awake by another app"
    case paused = "Paused"
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
    private let checkForUpdatesTarget: AnyObject?
    private let checkForUpdatesAction: Selector?

    private var pollingTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.aware.timer", qos: .userInitiated)
    private var isDisplaySleeping = false

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

    init(checkForUpdatesTarget: AnyObject? = nil, checkForUpdatesAction: Selector? = nil) {
        self.checkForUpdatesTarget = checkForUpdatesTarget
        self.checkForUpdatesAction = checkForUpdatesAction
        super.init()
        #if DEBUG
        debugLog("MenuBarController init started")
        #endif
        registerForPowerStateNotifications()
        setupStatusItem()
        updateMenu()
        if isEnabled {
            startPolling()
        }
        #if DEBUG
        debugLog("MenuBarController init complete. Status item button exists: \(statusItem.button != nil)")
        #endif
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
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

        let checkForUpdatesItem = NSMenuItem(title: "Check for Updates...", action: checkForUpdatesAction, keyEquivalent: "")
        checkForUpdatesItem.target = checkForUpdatesTarget
        checkForUpdatesItem.isEnabled = checkForUpdatesTarget != nil && checkForUpdatesAction != nil
        menu.addItem(checkForUpdatesItem)

        menu.addItem(NSMenuItem.separator())

        if #available(macOS 13.0, *) {
            let openAtLoginItem = NSMenuItem(title: "Open at Login", action: #selector(toggleOpenAtLogin), keyEquivalent: "")
            openAtLoginItem.target = self
            openAtLoginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
            menu.addItem(openAtLoginItem)
        }

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

        if #available(macOS 13.0, *), let openAtLoginItem = menu.items.first(where: { $0.title == "Open at Login" }) {
            openAtLoginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        }
    }

    @objc private func toggleOpenAtLogin() {
        guard #available(macOS 13.0, *) else { return }
        if SMAppService.mainApp.status == .enabled {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
        updateMenu()
    }

    private var isPollingPaused: Bool {
        isDisplaySleeping
    }

    private func registerForPowerStateNotifications() {
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleDisplaySleep),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleDisplayWake),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )

    }

    private func onEnabledChanged() {
        if isEnabled {
            startPolling()
        } else {
            pausePolling(setStatus: false)
            detectionStatus = .disabled
        }
        updateMenu()
    }

    private func startPolling() {
        guard isEnabled, !isPollingPaused else {
            detectionStatus = isEnabled ? .paused : .disabled
            return
        }
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

    private func pausePolling(setStatus: Bool) {
        stopPolling()
        presenceDetector.cancelPendingCapture()
        sleepAssertion.release()
        if setStatus, isEnabled {
            detectionStatus = .paused
        }
    }

    private func restartPollingTimer() {
        if isEnabled, !isPollingPaused {
            startPolling()
        }
        updateMenu()
    }

    private func performDetection() {
        guard isEnabled, !isPollingPaused else { return }

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

        // Skip camera check when another app (e.g. browser playing video) is already preventing sleep
        if externalSleepAssertionIsActive() {
            DispatchQueue.main.async { [weak self] in
                _ = self?.sleepAssertion.acquire()
                self?.detectionStatus = .externalAssertion
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
        guard isEnabled, !isPollingPaused else { return }

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

    @objc private func handleDisplaySleep() {
        isDisplaySleeping = true
        pausePolling(setStatus: true)
    }

    @objc private func handleDisplayWake() {
        isDisplaySleeping = false
        if isEnabled, !isPollingPaused {
            startPolling()
        } else {
            detectionStatus = .disabled
        }
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
}

#if DEBUG
private func debugLog(_ message: String) {
    let formatted = "[Aware] \(message)"
    print(formatted)
    NSLog("%@", formatted)
}
#endif
