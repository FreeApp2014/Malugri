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

    func readFile(path: String) -> Void {
        let file = FileHandle.init(forReadingAtPath: path)!.availableData;
        file.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let rawPtr = u8Ptr;
            readABrstm(rawPtr, 1, true);
        }
    }

    func createAudioBuffer() -> AVAudioPCMBuffer {
        let channelCount = gHEAD3_num_channels();
        format = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(gHEAD1_sample_rate()), channels: UInt32(channelCount), interleaved: false)
        let buffer = AVAudioPCMBuffer.init(pcmFormat: format, frameCapacity: UInt32(gwritten_samples()));
        buffer.frameLength = AVAudioFrameCount(gwritten_samples())
        let samples16 = gPCM_samples();
        var i: Int = 0;
        i = 0;
        var j: Int = 0;
        while (UInt32(j) < channelCount){
            while (UInt(i) < gwritten_samples()/UInt(channelCount)) {
                buffer.floatChannelData![j][i] =  Float32(Float32(samples16![j]![i]) / Float32(32768));
                i += 1;
            }
            i = 0;
            j += 1;
        };
        print(i);
        i = 0;
        return buffer;
    }

    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var playPause: NSButton!
    @IBOutlet weak var stop: NSButton!
    let am = AudioManager();
    
    @IBAction func pressBtn(_ sender: AnyObject) {
        let filePicker = NSOpenPanel();
        filePicker.allowsMultipleSelection = false;
        filePicker.allowedFileTypes = ["brstm"];
        filePicker.allowsOtherFileTypes = false;
        if (filePicker.runModal() == NSModalResponseOK){
            let fileUri = filePicker.url;
            if (fileUri != nil){
                let path = fileUri!.path;
                readFile(path: path);
                self.filenameLabel.stringValue = path;
                self.playPause.title = "Pause";
                self.stop.isEnabled = true;
                self.playPause.isEnabled = true;
                let buffer = createAudioBuffer();
                am.initialize(format: format);
                am.playBuffer(buffer: buffer);
                let newThread = DispatchQueue.global(qos: .background);
                self.progressBar.maxValue = floor(Double(gwritten_samples()) / (Double(gHEAD3_num_channels())*Double(gHEAD1_sample_rate())));
                print( self.progressBar.maxValue);
                newThread.async{
                    var i: Int = 0;
                    while (self.am.varPlay()){
                        if (self.am.state()) {
                            DispatchQueue.main.sync{
                                self.progressBar.increment(by: 1.0);
                            };
                        }
                        if (self.progressBar.doubleValue ==  self.progressBar.maxValue){
                            break;
                        }
                        Thread.sleep(forTimeInterval: 1.0);
                    }
                    DispatchQueue.main.sync{
                        self.progressBar.doubleValue = 0;
                        self.fileFinished();
                    };
                }
            }
        }
    }
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBAction func pressStop(_ sender: AnyObject) {
        am.stop();
        self.playPause.title = "Play";
        self.playPause.isEnabled = false;
        self.filenameLabel.stringValue = "No file loaded";
        self.stop.isEnabled = false;
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

