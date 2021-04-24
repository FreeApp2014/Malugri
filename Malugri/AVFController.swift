//
//  AVFController.swift
//  Malugri
//
//  Created by Free App on 19/04/2021.
//  Copyright © 2021 freeappsw. All rights reserved.
//

import Foundation
import AVFoundation

public class AVFController {
    private let avfFile: AVAudioFile;
    public init (filePath: URL) {
        self.avfFile = try! AVAudioFile(forReading: filePath, commonFormat: .pcmFormatInt16, interleaved: false);
    }
    
    public var samplesCount: UInt64 {
        get {
            return UInt64(avfFile.length);
        }
    }
    
    public var sampleRate: UInt64 {
        get {
            return UInt64(avfFile.fileFormat.sampleRate);
        }
    }
    
    public var channelCount: UInt32 {
        get {
            return UInt32(avfFile.fileFormat.channelCount);
        }
    }
    public var pcmBuffer: AVAudioPCMBuffer {
        get {
            let _pb = AVAudioPCMBuffer(pcmFormat: avfFile.processingFormat, frameCapacity: AVAudioFrameCount(avfFile.length));
            try! avfFile.read(into: _pb!);
            return _pb!;
        }
    }
    
    public static func avfPCMbuffer(PCMSamples: UnsafeMutablePointer<UnsafeMutablePointer<Int16>?>, length: UInt32, channelCount: Int, sampleRate: Double = Double(gHEAD1_sample_rate())) -> AVAudioPCMBuffer? {
        
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: sampleRate, channels: AVAudioChannelCount(channelCount), interleaved: false);
        let buffer = AVAudioPCMBuffer.init(pcmFormat: format!, frameCapacity: length);
        
        var i: Int = 0;
        var j: Int = 0;
        
        while (j < channelCount){
              while (UInt32(i) < length) {
                  buffer?.int16ChannelData![j][i] =  PCMSamples[j]![i];
                  i += 1;
              }
              i = 0;
              j += 1;
          }
        
        return buffer;
    }
    
    public static func writeFile(buffer: AVAudioPCMBuffer, format: AudioFormatID, saveTo: URL) {
        do {
            let file = try AVAudioFile(forWriting: saveTo,
                                        settings: [
                                            AVFormatIDKey: format,
                                            AVLinearPCMBitDepthKey: 16,
                                            AVLinearPCMIsFloatKey: false,
                                            //  AVLinearPCMIsBigEndianKey: false,
                                            AVSampleRateKey: buffer.format.sampleRate,
                                            AVNumberOfChannelsKey: buffer.format.channelCount
            ] as [String : Any],
                                        commonFormat: .pcmFormatInt16, interleaved: false);
            try file.write(from: buffer);
                
        } catch {
            MalugriUtil.popupAlert(title: "Error", message: error.localizedDescription);
        }
    }
}
