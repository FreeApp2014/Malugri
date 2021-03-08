//
//  ViewController.swift
//  Malugri
//
//  Created by Free App on 19/10/2020.
//  Copyright © 2020 freeappsw. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    // MARK: - Labels
    
    @IBOutlet weak var overviewLbl: NSTextField!
    @IBOutlet weak var codecLbl: NSTextField!
    @IBOutlet weak var loopBoolLbl: NSTextField!
    @IBOutlet weak var loopPointLbl: NSTextField!
    @IBOutlet weak var durationLbl: NSTextField!
    @IBOutlet weak var blockSizeLbl: NSTextField!
    @IBOutlet weak var fileLocation: NSPathControl!
    @IBOutlet weak var totalBlocksLbl: NSTextField!
    @IBOutlet weak var totalSamplesLbl: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        if let a = NSApplication.shared.mainWindow {
            var b: NSRect = a.frame;
            b.size.height = a.minSize.height;
            a.setFrame(b, display: true, animate: false)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    var playerController = MalugriPlayer(using: MGEZAudioBackend());
    
    func handleFile(path: String){
         do {
            try playerController.loadFile(file: path);
            playerController.backend.play();
            self.overviewLbl.stringValue = self.playerController.fileInformation.fileType + "・" + String(self.playerController.fileInformation.sampleRate) + " Hz";
            self.codecLbl.stringValue = self.playerController.fileInformation.codecString;
            self.loopBoolLbl.stringValue = self.playerController.fileInformation.looping ? "Yes" : "No";
            self.loopPointLbl.stringValue = String(self.playerController.fileInformation.loopPoint);
            self.fileLocation.url = URL(fileURLWithPath: path);
            self.blockSizeLbl.stringValue = String(self.playerController.fileInformation.blockSize);
            self.durationLbl.stringValue = self.playerController.fileInformation.duration.hmsString;
            self.totalBlocksLbl.stringValue = String(self.playerController.fileInformation.totalBlocks);
            self.totalSamplesLbl.stringValue = String(self.playerController.fileInformation.totalSamples);
            if let a = NSApplication.shared.mainWindow {
                a.title = String(path.split(separator: "/").last ?? "<unknown>") + " - Malugri";
            }
            } catch MGError.brstmReadError(let code, description) {
                   MalugriUtil.popupAlert(title: "Error opening file" ,
                                          message: "brstm_read: " + description + " (code " + String(code) + ")");
            } catch MGError.ifstreamError(let code) {
                   MalugriUtil.popupAlert(title: "Error opening file",
                                          message: "ifstream::open returned error code " + String(code))
            } catch {
                MalugriUtil.popupAlert(title: "Internal error",
                                        message: "An unexpected error has occurred.")
            }
    }
    
    @IBAction func openButton(_ sender: Any) {
        let filePicker = NSOpenPanel();
            filePicker.allowsMultipleSelection = false;
            filePicker.allowedFileTypes = ["brstm", "bwav", "bfstm", "bcstm"];
            filePicker.allowsOtherFileTypes = false;
            if (filePicker.runModal() == NSApplication.ModalResponse.OK){
                let fileUri = filePicker.url;
                if (fileUri != nil){
                    let path = fileUri!.path;
                    handleFile(path: path)
                }
            }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        self.playerController.backend.stop();
        self.playerController.closeFile();
    }
    
    @IBAction func playPause(_ sender: NSButtonCell) {
        sender.image = self.playerController.backend.state ? NSImage.init(imageLiteralResourceName: "NSTouchBarPlayTemplate") : NSImage.init(imageLiteralResourceName: "NSTouchBarPauseTemplate");
        self.playerController.backend.state ? self.playerController.backend.pause() : self.playerController.backend.resume();
    }
    
    @IBOutlet weak var infoBox: NSBox!
    
    @IBAction func expand(_ sender: NSButton) {
        if let a = NSApplication.shared.mainWindow {
            var newFrame: NSRect = a.frame;
            let diff = (sender.state == NSControl.StateValue.on ?  CGFloat(162) : -CGFloat(162));
            newFrame.size.height += diff
            a.maxSize.height += diff;
            a.minSize.height += diff;
            a.setFrame(newFrame, display: true, animate: true)
        }
    }
    
}