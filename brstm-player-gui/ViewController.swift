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
            return rawPtr
        }
    }

    func addBlocksToBuffer(fileData: UnsafePointer<UInt8>, blockCount: Int, buffer: UnsafeMutablePointer<AVAudioPCMBuffer>, offset: Int) -> Void {
        var e = 0;
        var off = offset;
        let channelCount = gHEAD3_num_channels();
        let samples32 =  UnsafeMutablePointer<UnsafeMutablePointer<Float32>>.allocate(capacity: Int(channelCount));
        var i = 0;
        while (UInt32(i) < channelCount){
            samples32[i] = UnsafeMutablePointer<Float32>.allocate(capacity: Int(gwritten_samples()));
            i+=1;
        }
        while (e < blockCount){
            let samples16 = getBufferBlock(fileData, UInt(off));
            var i: Int;
            i = Int(off);
            var j: Int = 0;
            while (UInt32(j) < channelCount){
                while (UInt(i) < gHEAD1_blocks_samples()/UInt(channelCount)) {
                    samples32[j][i] = Float32(Float32(samples16![j]![i]) / Float32(32768));
                    buffer.pointee.floatChannelData![j][i] = samples32[j][i];
                    i += 1;
                }
                i = Int(off);
                j += 1;
            };
            off += Int(gHEAD1_blocks_samples());
            e += 1;
        }
    }

    func createAudioBuffer(fileData: UnsafePointer<UInt8>) -> AVAudioPCMBuffer {
        let channelCount = gHEAD3_num_channels();
        format = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: Double(gHEAD1_sample_rate()), channels: UInt32(channelCount), interleaved: false)
        var buffer = AVAudioPCMBuffer.init(pcmFormat: format, frameCapacity: UInt32(gwritten_samples()));
        buffer.frameLength = AVAudioFrameCount(gwritten_samples());
        let ptr: UnsafeMutablePointer<AVAudioPCMBuffer> = UnsafeMutablePointer<AVAudioPCMBuffer>.allocate(capacity: 1);
        ptr.pointee = buffer;
        addBlocksToBuffer(fileData: fileData, blockCount: 10, buffer: ptr, offset: 0);
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
                let data = readFile(path: path, decode: false);
                let buffer = createAudioBuffer(fileData: data);
                let am = AudioManager();
                let ptr: UnsafeMutablePointer<AVAudioPCMBuffer> = UnsafeMutablePointer<AVAudioPCMBuffer>.allocate(capacity: 1);
                ptr.pointee = buffer;
                am.playBuffer(buffer: ptr, format: format);

            }
        }

    }

}

