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
}
