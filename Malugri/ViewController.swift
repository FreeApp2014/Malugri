//
//  ViewController.swift
//  Malugri
//
//  Created by Free App on 19/10/2020.
//  Copyright © 2020 freeappsw. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - IB Outlets
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var trackSwitcherDD: NSPopUpButton!
    
    // MARK: - Labels
    
    @IBOutlet weak var overviewLbl: NSTextField!
    @IBOutlet weak var codecLbl: NSTextField!
    @IBOutlet weak var loopBoolLbl: NSTextField!
    @IBOutlet weak var loopPointLbl: NSTextField!
    @IBOutlet weak var blockSizeLbl: NSTextField!
    @IBOutlet weak var fileLocation: NSPathControl!
    @IBOutlet weak var totalBlocksLbl: NSTextField!
    @IBOutlet weak var totalSamplesLbl: NSTextField!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var ElapsedTimeLabel: NSTextField!
    
    // MARK: - Buttons
    
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var stopBtn: NSButton!
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var expandButton: NSButton!
    
    // TODO: Handle the loop button
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        if let a = NSApplication.shared.mainWindow {
            var b: NSRect = a.frame;
            b.size.height = a.minSize.height;
            a.setFrame(b, display: true, animate: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(notify(_:)), name: Notification.Name("file"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(opener(_:)), name: Notification.Name("open"), object: nil);
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func opener(_ sender: Notification) -> Void {
        self.openButton("" as Any);
    }
    
    @objc func notify(_ sender: Notification) -> Void {
        if (self.playerController.currentFile != nil) {
            self.stopButton(self.stopBtn!);
        }
        handleFile(path: sender.object! as! String);
    }
    
    var playerController = MalugriPlayer(using: MGEZAudioBackend());
    
    func handleFile(path: String){
         do {
            try playerController.loadFile(file: path);
            playerController.backend.needsLoop = playerController.fileInformation.looping;
            playerController.backend.play();
            self.overviewLbl.stringValue = self.playerController.fileInformation.fileType + "・" + (self.playerController.fileInformation.numTracks > 1 ? "                                    " : (gHEAD3_num_channels(Int32(playerController.backend.currentTrack)) == 1 ? NSLocalizedString("Mono", comment: "") : NSLocalizedString("Stereo", comment: "") )) + "・" + String(self.playerController.fileInformation.sampleRate) + " " + NSLocalizedString("Hz", comment: "");
            if (self.playerController.fileInformation.numTracks > 1){
                let items = self.playerController.getChannelLayouts();
                self.trackSwitcherDD.removeAllItems();
                for item in items {
                    let lt = (item.1 == 1 ? NSLocalizedString("Mono", comment: "") : NSLocalizedString("Stereo", comment: ""));
                    self.trackSwitcherDD.addItem(withTitle: NSLocalizedString("TrackTS", comment: "") + " \(item.0): \(lt)");
                }
                self.trackSwitcherDD.isHidden = false;
            }
            self.codecLbl.stringValue = self.playerController.fileInformation.codecString;
            self.loopBoolLbl.stringValue = self.playerController.fileInformation.looping ? NSLocalizedString("Yes", comment: "") : NSLocalizedString("No", comment: "");
            self.loopPointLbl.stringValue = String(self.playerController.fileInformation.loopPoint);
            self.fileLocation.url = URL(fileURLWithPath: path);
            self.blockSizeLbl.stringValue = String(self.playerController.fileInformation.blockSize);
            self.totalBlocksLbl.stringValue = String(self.playerController.fileInformation.totalBlocks);
            self.totalSamplesLbl.stringValue = String(self.playerController.fileInformation.totalSamples);
            
            let aList = NSApplication.shared.windows;
            var currentWin: NSWindow? = nil;
            for win in aList {
                if let a = win.contentViewController, a == self {
                    currentWin = win;
                }
            }
            if let a = currentWin {
                a.title = String(path.split(separator: "/").last ?? "<unknown>") + " - Malugri";
            }
            
            self.timeSlider.minValue = 0.0;
            self.timeSlider.maxValue = Double(self.playerController.fileInformation.totalSamples - 1);
            self.playPauseButton.isEnabled = true;
            self.stopBtn.isEnabled = true;
            self.expandButton.isEnabled = true;
            self.timeSlider.isEnabled = true;
            // Reserved for implementing of the export functions
            // NotificationCenter.default.post(name: Notification.Name("exportStatus"), object: true);
            DispatchQueue.global().async {
                while (self.playerController.backend.state) {
                    DispatchQueue.main.async {
                        self.ElapsedTimeLabel.stringValue = Int(self.playerController.backend.currentSampleNumber / self.playerController.fileInformation.sampleRate).hmsString + " / " + self.playerController.fileInformation.duration.hmsString;
                        self.timeSlider.floatValue = Float(self.playerController.backend.currentSampleNumber);
                    }
                    Thread.sleep(forTimeInterval: 0.25);
                }
            }

        } catch MGError.brstmReadError(let code, let desc) {
            MalugriUtil.popupAlert(title: NSLocalizedString("Error opening file", comment:"") ,
                                   message: "brstm_read: " + desc + " (" + NSLocalizedString("bLCode", comment:"") + " " + String(code) + ")");
        } catch MGError.ifstreamError(let code) {
                MalugriUtil.popupAlert(title: NSLocalizedString("Error opening file", comment:""),
                                          message: "ifstream::open returned error code " + String(code))
        } catch {
            print(error);
            MalugriUtil.popupAlert(title: NSLocalizedString("Internal error", comment:""),
                                        message: "An unexpected error has occurred.")
        }
    }
    
    // MARK: - IB Actions
    
    @IBAction func openButton(_ sender: Any) {
        let filePicker = NSOpenPanel();
            filePicker.allowsMultipleSelection = false;
        filePicker.allowedFileTypes = ["brstm", "bwav", "bfstm", "bcstm", "bcwav", "bfwav"];
            filePicker.allowsOtherFileTypes = false;
            if (filePicker.runModal() == NSApplication.ModalResponse.OK){
                let fileUri = filePicker.url;
                if (fileUri != nil){
                    if (self.playerController.currentFile != nil) {
                        self.stopButton(self.stopBtn!);
                    }
                    let path = fileUri!.path;
                    handleFile(path: path);
                }
            }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        self.playerController.backend.stop();
        self.playerController.closeFile();
        self.playPauseButton.isEnabled = false;
        self.stopBtn.isEnabled = false;
        self.expandButton.isEnabled = false;
        self.timeSlider.isEnabled = false;
        self.trackSwitcherDD.isHidden = true;
        self.timeSlider.floatValue = 0.0;
        self.playPauseButton.image = NSImage.init(imageLiteralResourceName: "NSTouchBarPauseTemplate");
        self.overviewLbl.stringValue = "";
        if let a = NSApplication.shared.mainWindow {
            a.title = "Malugri";
        }
        self.ElapsedTimeLabel.stringValue = "";
        NotificationCenter.default.post(name: Notification.Name("exportStatus"), object: false);
    }
    
    @IBAction func playPause(_ sender: NSButtonCell) {
        sender.image = self.playerController.backend.state ? NSImage.init(imageLiteralResourceName: "NSTouchBarPlayTemplate") : NSImage.init(imageLiteralResourceName: "NSTouchBarPauseTemplate");
        if (self.playerController.backend.state) {
            self.playerController.backend.pause();
        } else {
            self.playerController.backend.resume();
            DispatchQueue.global().async {
                       while (self.playerController.backend.state) {
                           DispatchQueue.main.async {
                               self.ElapsedTimeLabel.stringValue = Int(self.playerController.backend.currentSampleNumber / self.playerController.fileInformation.sampleRate).hmsString + " / " + self.playerController.fileInformation.duration.hmsString;
                               self.timeSlider.floatValue = Float(self.playerController.backend.currentSampleNumber);
                           }
                           Thread.sleep(forTimeInterval: 0.25);
                       }
                   }
        }
    }
    
    
    @IBAction func expand(_ sender: NSButton) {
        if let a = NSApplication.shared.mainWindow {
            var newFrame: NSRect = a.frame;
            let diff = (sender.state == NSControl.StateValue.on ?  CGFloat(124) : -CGFloat(124));
            self.infoBox.isHidden = (sender.state == NSControl.StateValue.on ?  false : true);
            newFrame.size.height += diff
            a.maxSize.height += diff;
            a.minSize.height += diff;
            a.setFrame(newFrame, display: true, animate: true)
        }
    }
    
    @IBAction func changePosition(_ sender: Any) {
        self.playerController.backend.currentSampleNumber = UInt((sender as! NSSlider).floatValue);
    }
    @IBAction func trackChange(_ sender: NSPopUpButton) {
        print(sender.indexOfSelectedItem);
        self.playerController.backend.currentTrack = UInt32(sender.indexOfSelectedItem);
    }
}
