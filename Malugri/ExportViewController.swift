//
//  ExportViewController.swift
//  Malugri
//
//  Created by Free App on 23/04/2021.
//  Copyright © 2021 freeappsw. All rights reserved.
//

import Cocoa

class ExportViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(beginTranscode(_:)), name: NSNotification.Name("beginTranscode"), object: nil)
    }
    
    @objc func beginTranscode(_ sender: Notification) {
        //let tuple = sender.object as! MalugriPlayer;
    }
    
}
