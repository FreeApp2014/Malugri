//
//  BWViewController.swift
//  Malugri
//
//  Created by Free App on 19/04/2021.
//  Copyright © 2021 freeappsw. All rights reserved.
//

import Cocoa

class BWViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var inputNPC: NSPathControl!
    @IBOutlet weak var outputNPC: NSPathControl!
    @IBOutlet weak var format: NSPopUpButton!
    @IBOutlet weak var codec: NSPopUpButton!
    @IBOutlet weak var loopCB: NSButton!
    @IBOutlet weak var loopPoint: NSTextField!
    @IBOutlet weak var spin: NSProgressIndicator!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var encBtn: NSButton!
    @IBOutlet weak var chooseInput: NSButton!
    @IBOutlet weak var chooseOutput: NSButton!
    
    private var loadedFile: URL = URL(fileURLWithPath: "/");
    private var savedFile = "";
    
    // MARK: - Actions
    
    @IBAction func fileOpen(_ sender: Any) {
        let filePicker = NSOpenPanel();
        filePicker.allowsMultipleSelection = false;
        filePicker.allowedFileTypes = ["public.audio"];
        filePicker.allowsOtherFileTypes = false;
        if (filePicker.runModal() == NSApplication.ModalResponse.OK){
            let fileUri = filePicker.url;
            if (fileUri != nil){
                loadedFile = fileUri!;
                inputNPC.url = fileUri!;
                inputNPC.isHidden = false;
                if (savedFile != "") {
                    encBtn.isEnabled = true;
                }
            }
        }
    }
    @IBAction func fileSave(_ sender: Any) {
        let savePanel = NSSavePanel();
        var filename = String(loadedFile.path.split(separator: "/").last!).split(separator: ".");
        filename.removeLast();
        savePanel.nameFieldStringValue = filename.joined(separator: ".") + ".encode." + format.itemTitle(at: format.indexOfSelectedItem).lowercased();
        if (savePanel.runModal() == NSApplication.ModalResponse.OK){
            let fileUri = savePanel.url;
            if (fileUri != nil){
                savedFile = fileUri!.path;
                outputNPC.url = fileUri!;
                outputNPC.isHidden = false;
                if (loadedFile.path != "/") {
                    encBtn.isEnabled = true;
                }
            }
        }
        
    }
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        if (sender.state == .on) {
            self.loopPoint.isHidden = false;
        } else {
            self.loopPoint.isHidden = true;
        }
    }
    
    // MARK: - The encode process
    
    @IBAction func encodeButton(_ sender: Any) {
        let avf = AVFController(filePath: self.loadedFile);
        print(avf.sampleRate);
        print(avf.channelCount);
        print(avf.samplesCount);
        self.spin.isHidden = false;
        self.spin.startAnimation(nil);
        self.status.stringValue = "Processing input file...";
        self.status.isHidden = false;
        self.encBtn.isEnabled = false;
        self.format.isEnabled = false;
        self.codec.isEnabled = false;
        self.loopCB.isEnabled = false;
        self.loopPoint.isEnabled = false;
        self.chooseInput.isEnabled = false;
        self.chooseOutput.isEnabled = false;
        setBrstmEncodeSettings(UInt32(self.format.indexOfSelectedItem + 1), UInt32(self.codec.indexOfSelectedItem + 1), UInt32(avf.channelCount), 1, self.loopCB.state == .on ? 1 : 0, self.loopCB.state == .off ? 0 : UInt(self.loopPoint.stringValue) ?? 0, UInt(avf.sampleRate), UInt(avf.samplesCount));
        DispatchQueue.global().async {
            let pb = avf.pcmBuffer;
            for channel in 0..<Int(avf.channelCount) {
                writeSamplesToChannel(Int32(channel), pb.int16ChannelData?[channel], UInt(avf.samplesCount * UInt64(avf.channelCount)));
            }
            DispatchQueue.main.sync {
                self.status.stringValue = "Encoding \(self.format.itemTitle(at: self.format.indexOfSelectedItem))...";
            }
            let st = runEncoder(1);
            print(st);
            if (st > 127) {
                DispatchQueue.main.sync {
                    MalugriUtil.popupAlert(title: "Encoding error", message: "An unexpected error occured encoding the file:\nbrstm_encode: \(st)");
                    self.spin.isHidden = true;
                    self.status.isHidden = true;
                    self.spin.stopAnimation(nil);
                    self.encBtn.isEnabled = true;
                    self.format.isEnabled = true;
                    self.codec.isEnabled = true;
                    self.loopCB.isEnabled = true;
                    self.loopPoint.isEnabled = true;
                    self.chooseInput.isEnabled = true;
                    self.chooseOutput.isEnabled = true;
                }
                return;
            };
            let fileData: UnsafeMutablePointer<UInt8>? = getEncFile();
            let size = gEFileSize();
            DispatchQueue.main.sync {
                self.status.stringValue = "Writing output file...";
            }
            let data = NSData(bytesNoCopy: fileData!, length: Int(size), freeWhenDone: false);
            data.write(toFile:self.savedFile, atomically: true);
            DispatchQueue.main.sync {
                self.spin.isHidden = true;
                self.status.isHidden = true;
                self.spin.stopAnimation(nil);
                closeEbrstm();
                let alert: NSAlert = NSAlert();
                alert.messageText = "Encoding complete";
                alert.informativeText = "File saved to " + self.savedFile;
                alert.addButton(withTitle: "OK");
                alert.addButton(withTitle: "Open file");
                 if let a = NSApplication.shared.mainWindow {
                    alert.beginSheetModal(for: a, completionHandler: { response in
                        if (response == .alertSecondButtonReturn){
                            let nc = NotificationCenter.default
                            nc.post(name: Notification.Name("file"), object: self.savedFile);
                            
                        }
                        
                        let aList = NSApplication.shared.windows;
                        var currentWin: NSWindow? = nil;
                        for win in aList {
                            if let a = win.contentViewController, a == self {
                                currentWin = win;
                            }
                        }
                        if let a = currentWin {
                            a.close();
                        }
                    })
                }
            }
        }
    }
}
