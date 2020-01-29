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

    func readFile(path: String, decode: Bool = true) -> UnsafePointer<UInt8> {
        let file = FileHandle.init(forReadingAtPath: path)!.availableData;
        return file.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let rawPtr = u8Ptr;
            readABrstm(rawPtr, 1, decode);
            let channelCount = gHEAD3_num_channels();
            format = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(gHEAD1_sample_rate()), channels: UInt32(channelCount), interleaved: false)
            return rawPtr;
        }
    }

    func getBlockBuffer(fileData: UnsafePointer<UInt8>, offset: Int) -> AVAudioPCMBuffer {
        let channelCount = gHEAD3_num_channels();
        let buffer = AVAudioPCMBuffer.init(pcmFormat: format, frameCapacity: UInt32(gHEAD1_blocks_samples()));
        buffer.frameLength = AVAudioFrameCount(gHEAD1_blocks_samples());
        let samples16 = getBufferBlock(fileData, UInt(offset));
        var i: Int;
        i = Int(offset);
        var j: Int = 0;
        while (UInt32(j) < channelCount){
            while (UInt(i) < gHEAD1_blocks_samples()/UInt(channelCount)) {
                //print(i,j,Float32(Float32(samples16![j]![i]) / Float32(32768)));
                buffer.floatChannelData![j][i] = Float32(Float32(samples16![j]![i]) / Float32(32768));
                i += 1;
            }
            j += 1;
            i = Int(offset);
        };
        return buffer;
    }

    func createAudioBuffer(fileData: UnsafePointer<UInt8>) -> AVAudioPCMBuffer {
        return getBlockBuffer(fileData: fileData, offset: 0);
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
                let data = readFile(path: path, decode: false);
                let am = AudioManager();
                am.initialize(format: format);
                am.playBuffer(buffer: getBlockBuffer(fileData: data, offset: 0));
                var i = 3;
                while (UInt(i) < gHEAD1_total_samples()/gHEAD1_blocks_samples()){
                    am.playBuffer(buffer: getBlockBuffer(fileData: data, offset: Int(gHEAD1_blocks_samples()*UInt(i))));
                    Thread.sleep(forTimeInterval: Double(Int(gHEAD1_blocks_samples()) / Int(gHEAD1_sample_rate())));
                    i+=1
                }
                //
                //a;
            }
        }

    }

}

