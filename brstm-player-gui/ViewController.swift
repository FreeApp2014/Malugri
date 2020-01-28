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
        format = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(gaHEAD1_sample_rate()), channels: UInt32(channelCount), interleaved: false)
        var buffer = AVAudioPCMBuffer.init(pcmFormat: format, frameCapacity: UInt32(gawritten_samples()));
        buffer.frameLength = AVAudioFrameCount(gawritten_samples())
        let samples16 = gaPCM_samples();
        let samples32 =  UnsafeMutablePointer<UnsafeMutablePointer<Float32>>.allocate(capacity: Int(channelCount));
        var i: Int = 0;
        while (UInt32(i) < channelCount){
            samples32[i] = UnsafeMutablePointer<Float32>.allocate(capacity: Int(gawritten_samples()));
            i+=1;
        }
        i = 0;
        var j: Int = 0;
        while (UInt32(j) < channelCount){
            while (UInt(i) < gawritten_samples()/UInt(channelCount)) {
                samples32[j][i] = Float32(Float32(samples16![j]![i]) / Float32(32768));
                buffer.floatChannelData![j][i] = samples32[j][i];
                i += 1;
            }
            i = 0;
            j += 1;
        };
        print(i);
        i = 0;
        return buffer;
    }


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
                let buffer = createAudioBuffer();
                let am = AudioManager();
                am.playToEnd(buffer: buffer, format: format);
            }
        }

    }

}

