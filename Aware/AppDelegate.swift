//
//  AppDelegate.swift
//  Aware
//
//  App entry point. Creates MenuBarController and configures NSApplication.
//

import AppKit
import Sparkle

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var launchWindow: NSWindow?
    private weak var welcomeCheckbox: NSButton?
    private let updaterController: SPUStandardUpdaterController?

    private let hasSeenWelcomeKey = "aware.hasSeenWelcome"

    override init() {
        if Self.hasUpdaterConfiguration {
            updaterController = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: nil,
                userDriverDelegate: nil
            )
        } else {
            updaterController = nil
        }

        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        #if DEBUG
        debugLog("Aware launching...")
        if updaterController == nil {
            debugLog("Sparkle updater is disabled because SUPublicEDKey is not configured yet")
        }
        #endif

        // Defer status item creation so the menu bar is ready (fixes icon not appearing when launched by script)
        DispatchQueue.main.async { [weak self] in
            self?.menuBarController = MenuBarController(
                checkForUpdatesTarget: self?.updaterController,
                checkForUpdatesAction: self?.checkForUpdatesAction
            )
            self?.showWelcomeIfNeeded()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private var checkForUpdatesAction: Selector? {
        guard updaterController != nil else { return nil }
        return #selector(SPUStandardUpdaterController.checkForUpdates(_:))
    }

    private static var hasUpdaterConfiguration: Bool {
        guard
            let infoDictionary = Bundle.main.infoDictionary,
            let publicKey = (infoDictionary["SUPublicEDKey"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return false
        }

        return !publicKey.isEmpty
    }

    private func showWelcomeIfNeeded() {
        if UserDefaults.standard.bool(forKey: hasSeenWelcomeKey) { return }

        NSApp.activate(ignoringOtherApps: true)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Welcome to Aware"
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating

        let stack = NSStackView(views: [])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        let title = NSTextField(labelWithString: "Welcome to Aware")
        title.font = .boldSystemFont(ofSize: 15)
        title.alignment = .center
        stack.addArrangedSubview(title)

        let info = NSTextField(labelWithString: "Aware keeps your display awake by detecting your presence with the FaceTime camera. Click the person icon in the menu bar to enable.")
        info.font = .systemFont(ofSize: 11)
        info.maximumNumberOfLines = 0
        info.lineBreakMode = .byWordWrapping
        info.alignment = .center
        info.cell?.truncatesLastVisibleLine = false
        info.preferredMaxLayoutWidth = 260
        stack.addArrangedSubview(info)

        let checkbox = NSButton(checkboxWithTitle: "Do not show this window again", target: nil, action: nil)
        stack.addArrangedSubview(checkbox)

        let dismissButton = NSButton(title: "Get Started", target: self, action: #selector(dismissWelcome(_:)))
        dismissButton.bezelStyle = .rounded
        stack.addArrangedSubview(dismissButton)

        let content = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 200))
        window.contentView = content
        content.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: content.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -24),
        ])

        welcomeCheckbox = checkbox
        launchWindow = window
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func dismissWelcome(_ sender: NSButton) {
        if welcomeCheckbox?.state == .on {
            UserDefaults.standard.set(true, forKey: hasSeenWelcomeKey)
        }
        launchWindow?.orderOut(nil)
        launchWindow = nil
        welcomeCheckbox = nil
    }
}

#if DEBUG
private func debugLog(_ message: String) {
    let formatted = "[Aware] \(message)"
    print(formatted)
    NSLog("%@", formatted)
}
#endif
