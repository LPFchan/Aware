//
//  AppDelegate.swift
//  Aware
//
//  App entry point. Creates MenuBarController and configures NSApplication.
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var launchWindow: NSWindow?

    private static let logPath: String = {
        (NSHomeDirectory() as NSString).appendingPathComponent("Desktop/aware-launch-log.txt")
    }()

    private static func log(_ message: String) {
        let line = "\(ISO8601DateFormatter().string(from: Date())) \(message)\n"
        if FileManager.default.fileExists(atPath: logPath) {
            if let handle = FileHandle(forWritingAtPath: logPath) {
                handle.seekToEndOfFile()
                handle.write(line.data(using: .utf8)!)
                try? handle.close()
            }
        } else {
            try? line.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        Self.log("applicationWillFinishLaunching")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.log("applicationDidFinishLaunching START")

        // Play system beep so you know something happened (even if alert is on another display)
        NSSound.beep()

        // Immediate modal alert — blocks until dismissed.
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Aware Launch Diagnostic"
        alert.informativeText = """
        If you see this, Aware launched.

        Check your Desktop for aware-launch-log.txt
        Full path: \(Self.logPath)
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()

        Self.log("applicationDidFinishLaunching AFTER alert")

        // Required for menu bar apps: accessory policy allows status item without Dock icon
        NSApp.setActivationPolicy(.accessory)

        #if DEBUG
        debugLog("Aware launching...")
        #endif

        menuBarController = MenuBarController()
        showLaunchWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func showLaunchWindow() {
        NSApp.activate(ignoringOtherApps: true)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Aware"
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating

        let stack = NSStackView(views: [])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let title = NSTextField(labelWithString: "Aware is running")
        title.font = .boldSystemFont(ofSize: 16)
        stack.addArrangedSubview(title)

        let info = NSTextField(labelWithString: """
        The menu bar control shows "Aware" or a person icon at the top-right of your screen.

        If you don't see it, click the Control Center icon (two sliders) in the menu bar to reveal hidden items.
        """)
        info.font = .systemFont(ofSize: 12)
        info.maximumNumberOfLines = 0
        info.lineBreakMode = .byWordWrapping
        info.cell?.truncatesLastVisibleLine = false
        info.preferredMaxLayoutWidth = 320
        stack.addArrangedSubview(info)

        let dismissButton = NSButton(title: "Dismiss", target: self, action: #selector(dismissLaunchWindow))
        dismissButton.bezelStyle = .rounded
        stack.addArrangedSubview(dismissButton)

        let content = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 220))
        window.contentView = content
        content.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
        ])

        launchWindow = window
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func dismissLaunchWindow() {
        launchWindow?.orderOut(nil)
        launchWindow = nil
    }
}

#if DEBUG
private func debugLog(_ message: String) {
    let formatted = "[Aware] \(message)"
    print(formatted)
    NSLog("%@", formatted)
}
#endif
