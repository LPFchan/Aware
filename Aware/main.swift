//
//  main.swift
//  Aware
//

import AppKit

let app = NSApplication.shared
let appDelegate = AppDelegate()  // Strong reference required—delegate property is weak
app.delegate = appDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
