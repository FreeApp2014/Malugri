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
    
    
    @IBOutlet weak var inputNPC: NSPathControl!
    @IBOutlet weak var outputNPC: NSPathControl!
    @IBOutlet weak var format: NSPopUpButton!
    @IBOutlet weak var codec: NSPopUpButton!
    @IBOutlet weak var loopCB: NSButton!
    @IBOutlet weak var loopPoint: NSTextField!
    @IBOutlet weak var spin: NSProgressIndicator!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var encBtn: NSButton!
    
    private var loadedFile: URL = URL(fileURLWithPath: "/");
    private var savedFile = "";
    
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
        savePanel.nameFieldStringValue = "encode.brstm";
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
    
    @IBAction func encodeButton(_ sender: Any) {
        let avf = AVFController(filePath: self.loadedFile);
        print(avf.sampleRate);
        print(avf.channelCount);
        print(avf.samplesCount);
        self.spin.isHidden = false;
        self.spin.startAnimation(nil);
        self.status.stringValue = "Encoding...";
        self.status.isHidden = false;
        setBrstmEncodeSettings(UInt32(self.format.indexOfSelectedItem + 1), UInt32(self.codec.indexOfSelectedItem + 1), UInt32(avf.channelCount), 1, self.loopCB.state == .on ? 1 : 0, self.loopCB.state == .off ? 0 : UInt(self.loopPoint.stringValue) ?? 0, UInt(avf.sampleRate), UInt(avf.samplesCount));
        DispatchQueue.global().async {
            let pb = avf.pcmBuffer;
            for channel in 0..<Int(avf.channelCount) {
                writeSamplesToChannel(Int32(channel), pb.int16ChannelData?[channel], UInt(avf.samplesCount * UInt64(avf.channelCount)));
            }
            let st = runEncoder(1);
            print(st);
            if (st > 127) {
                DispatchQueue.main.sync {
                    MalugriUtil.popupAlert(title: "Encoding error", message: "An unexpected error occured encoding the file:\nbrstm_encode: \(st)");
                    self.spin.isHidden = true;
                    self.status.isHidden = true;
                    self.spin.stopAnimation(nil);
                }
                return;
            };
            let fileData: UnsafeMutablePointer<UInt8>? = getEncFile();
            let size = gEFileSize();
            DispatchQueue.main.sync {
                self.status.stringValue = "Writing file...";
            }
            let data = NSData(bytesNoCopy: fileData!, length: Int(size), freeWhenDone: false);
            data.write(toFile:self.savedFile, atomically: true);
            DispatchQueue.main.sync {
                self.spin.isHidden = true;
                self.status.isHidden = true;
                self.spin.stopAnimation(nil);
                closeEbrstm();
            }
        }
    }
}
