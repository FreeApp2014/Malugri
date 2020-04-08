//
//  ViewController.swift
//  brstm-player-gui
//
//  Created by admin on 27/01/20.
//  Copyright © 2020 FreeAppSW. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation

var format: AVAudioFormat = AVAudioFormat();
var secLen: Double = 0.0;
var decodeMode: Int = 0;

func createAudioBuffer(_ PCMSamples: UnsafeMutablePointer<UnsafeMutablePointer<Int16>?>, offset: Int, needToInitFormat: Bool) -> AVAudioPCMBuffer {
    let channelCount = (gHEAD3_num_channels() > 2 ? 2 : gHEAD3_num_channels());
    if (needToInitFormat) {format = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(gHEAD1_sample_rate()), channels: UInt32(channelCount), interleaved: false)!;}
    let buffer = AVAudioPCMBuffer.init(pcmFormat: format, frameCapacity: UInt32((Int(gHEAD1_total_samples()) - offset)));
    buffer!.frameLength = AVAudioFrameCount(UInt32(Int(gHEAD1_total_samples()) - offset));
    var i: Int = 0;
    i = 0;
    var j: Int = 0;
    while (UInt32(j) < channelCount){
        while (UInt(i) < UInt((Int(gHEAD1_total_samples()) - offset))) {
            buffer?.floatChannelData![j][i] =  Float32(Float32(PCMSamples[j]![i+offset]) / Float32(32768));
            i += 1;
        }
        i = 0;
        j += 1;
    };
    print(i);
    i = 0;
    return buffer!;
}

func createBlockBuffer(_ blockbuffer: UnsafeMutablePointer<UnsafeMutablePointer<Int16>?>, needToInitFormat: Bool) -> AVAudioPCMBuffer {
    let channelCount = (gHEAD3_num_channels() > 2 ? 2 : gHEAD3_num_channels());
    if (needToInitFormat) {format = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(gHEAD1_sample_rate()), channels: UInt32(channelCount), interleaved: false)!;}
    let buffer = AVAudioPCMBuffer.init(pcmFormat: format, frameCapacity: UInt32(gHEAD1_blocks_samples()));
    buffer!.frameLength = AVAudioFrameCount(UInt32(gHEAD1_blocks_samples()));
    let samples16 = blockbuffer;
    var i: Int = 0;
    i = 0;
    var j: Int = 0;
    while (UInt32(j) < channelCount){
        while (UInt(i) < gHEAD1_blocks_samples()) {
            buffer?.floatChannelData![j][i] =  Float32(Float32(samples16[j]![i]) / Float32(32768));
            i += 1;
        }
        i = 0;
        j += 1;
    };
    print(i);
    i = 0;
    return buffer!;
}


class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(notify(_:)), name: Notification.Name("file"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(opener(_:)), name: Notification.Name("opener"), object: nil);
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func notify(_ sender: Notification) -> Void {
        handleFile(path: sender.object! as! String);
    }

    @objc func opener(_ sender: Notification) -> Void {
        pressBtn(self.stop);
    }
    func readFile(path: String) -> Void {
        var filesize: UInt64 = 0;
         do {
            let fileat = try FileManager.default.attributesOfItem(atPath: path);
            filesize = fileat[.size] as? UInt64 ?? UInt64(0);
            if (filesize >= 5000000 && self.choiceGB.indexOfSelectedItem == 0) {
                decodeMode = 1;
            } else if (self.choiceGB.indexOfSelectedItem == 1){
                decodeMode = 0;
            } else if (self.choiceGB.indexOfSelectedItem == 2) {
                decodeMode = 1;
            }
        } catch let error as NSError {
            print("FileAttribute error: \(error)");
            return;
        }
        let file = FileHandle.init(forReadingAtPath: path)!.availableData;
        file.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            initStruct();
            readABrstm(u8Ptr, 1, decodeMode == 0);
            let pointer: UnsafePointer<Int8>? = NSString(string: path).utf8String;
            createIFSTREAMObject(strdup(pointer)!);
        }
        
    }

    @IBOutlet weak var choiceGB: NSPopUpButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var playPause: NSButton!
    @IBOutlet weak var stop: NSButton!
    let am = AudioManager();
    @IBAction func pressBtn(_ sender: AnyObject) {
        let filePicker = NSOpenPanel();
        filePicker.allowsMultipleSelection = false;
        filePicker.allowedFileTypes = ["brstm"];
        filePicker.allowsOtherFileTypes = false;
        if (filePicker.runModal() == NSApplication.ModalResponse.OK){
            let fileUri = filePicker.url;
            if (fileUri != nil){
                let path = fileUri!.path;
                handleFile(path: path)
            }
        }
    }

    func handleFile(path: String) {
        readFile(path: path);
        if(am.wasUsed){
            self.pressStop(self.stop);
            print("a");
            self.am.i = 0;
            Thread.sleep(forTimeInterval: 0.05);
        }
        self.filenameLabel.stringValue = path;
        self.playPause.title = "Pause";
        self.stop.isEnabled = true;
        self.playPause.isEnabled = true;
        switch (decodeMode){
        case 0:
            let buffer = createAudioBuffer(gPCM_samples(), offset: 0, needToInitFormat: true);
            am.initialize(format: format);
            self.am.playBuffer(buffer: buffer);
            am.genPB();
            break;
        case 1:
            let blockbuffer = getBufferBlock(0);
            let buffer = createBlockBuffer(blockbuffer!, needToInitFormat: true);
            am.initialize(format: format);
            self.am.playBuffer(buffer: buffer);
            break
        default:
            print("if this is printed then idk what happened to this world")
        }
        let newThread = DispatchQueue.global(qos: .background);
        self.progressBar.maxValue = floor(Double(gHEAD1_total_samples()) / Double(gHEAD1_sample_rate()));
        print( self.progressBar.maxValue);
        secLen = self.progressBar.maxValue;
        newThread.async{
            while (self.am.varPlay() || self.am.needsLoop){
                if (self.am.state()) {
                    DispatchQueue.main.sync{
                        self.progressBar.doubleValue = self.am.i;
                        self.statusLabel.stringValue =  String(Int(ceil(self.am.i))) + " / " + String(Int(self.progressBar.maxValue)) + " s."
                    };
                }
                Thread.sleep(forTimeInterval: 0.5);
            }
            DispatchQueue.main.sync{
                self.progressBar.doubleValue = 0;
                self.fileFinished();
            };
        }
    }

    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBAction func pressStop(_ sender: AnyObject) {
        am.stopBtn();
        self.playPause.title = "Play";
        self.playPause.isEnabled = false;
        self.filenameLabel.stringValue = "No file loaded";
        self.stop.isEnabled = false;
        am.i = 0;
    }
    @IBAction func PlayPausePress(_ sender: AnyObject) {
        if (am.state()){
            am.pause();
            self.playPause.title = "Play";
        } else {
            am.resume();
            self.playPause.title = "Pause";
        }
    }
    public func fileFinished() -> Void {
        self.filenameLabel.stringValue = "No file loaded";
        self.playPause.title = "Play";
        self.playPause.isEnabled = false;
        self.stop.isEnabled = false;
    }
}

