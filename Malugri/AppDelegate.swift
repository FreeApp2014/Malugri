//
//  AppDelegate.swift
//  Malugri
//
//  Created by Free App on 19/10/2020.
//  Copyright © 2020 freeappsw. All rights reserved.
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
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("file"), object: filename);
        return true;
    }
    @IBAction func openButton(_ sender: Any) {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("open"), object: nil);
    }
    @IBAction func newButton(_ sender: Any) {
        var myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "bwWindow") as! NSWindowController;
        myWindowController.showWindow(self)
    }
}

