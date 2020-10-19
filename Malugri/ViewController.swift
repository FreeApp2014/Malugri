//
//  ViewController.swift
//  Malugri
//
//  Created by Free App on 19/10/2020.
//  Copyright © 2020 freeappsw. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func stopButton(_ sender: Any) {
        
    }
    @IBAction func playPause(_ sender: NSButtonCell) {
        sender.image = NSImage.init(imageLiteralResourceName: "NSTouchBarPlayTemplate")
    }
    
    @IBOutlet weak var infoBox: NSBox!
    
    @IBAction func expand(_ sender: NSButton) {
        if let a = NSApplication.shared.mainWindow {
            var newFrame: NSRect = a.frame;
            let diff = (sender.state == NSControl.StateValue.on ?  CGFloat(162) : CGFloat(-162));
            newFrame.size.height += diff
            a.maxSize.height += diff;
            a.setFrame(newFrame, display: true, animate: true)
        }
    }
    
}

