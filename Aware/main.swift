//
//  main.swift
//  Aware
//
//  Custom entry point to log before any AppKit lifecycle.
//  If aware-launch-log.txt gets "main.swift START", the process at least began.
//

import AppKit

// Use /tmp for first ping - most reliable, no Desktop permission issues
let logPath = "/tmp/aware-launch-log.txt"
print("[Aware] main.swift starting...")
let timestamp = ISO8601DateFormatter().string(from: Date())
try? "\(timestamp) main.swift START - process launched\n".write(toFile: logPath, atomically: true, encoding: .utf8)

let app = NSApplication.shared
let appDelegate = AppDelegate()  // Strong reference required—delegate property is weak
app.delegate = appDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
