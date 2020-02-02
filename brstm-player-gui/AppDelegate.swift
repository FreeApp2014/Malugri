//
//  AppDelegate.swift
//  brstm-player-gui
//
//  Created by admin on 27/01/20.
//  Copyright © 2020 FreeAppSW. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool{
        return true;
    }

    @IBAction func fileOpenClick(_ sender: AnyObject) {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("opener"), object: nil);
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("file"), object: filename);
        return true;
    }
}

