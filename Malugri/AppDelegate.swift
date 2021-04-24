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


    @IBOutlet weak var exportMenu: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.exportMenu.isEnabled = false;
        
        NotificationCenter.default.addObserver(self, selector: #selector(unlockExport(_:)), name: Notification.Name("exportStatus"), object: nil)
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
    
    @objc func unlockExport(_ sender: Notification) {
        self.exportMenu.isEnabled = sender.object as! Bool;
    }
    
    @IBAction func openButton(_ sender: Any) {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("open"), object: nil);
    }
    @IBAction func newButton(_ sender: Any) {
        let myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "bwWindow") as! NSWindowController;
        myWindowController.showWindow(self)
    }
    @IBAction func exportWAVbutton(_ sender: Any) {
        let myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "exportWindow") as! NSWindowController;
        myWindowController.showWindow(self);
        NotificationCenter.default.post(name: Notification.Name("beginConvert"), object: "wav");
    }
    @IBAction func exportAACbutton(_ sender: Any) {
        let myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "exportWindow") as! NSWindowController;
        myWindowController.showWindow(self);
        NotificationCenter.default.post(name: Notification.Name("beginConvert"), object: "aac");
    }
    @IBAction func exportALACbutton(_ sender: Any) {
        let myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "exportWindow") as! NSWindowController;
        myWindowController.showWindow(self);
        NotificationCenter.default.post(name: Notification.Name("beginConvert"), object: "alac");
    }
}

