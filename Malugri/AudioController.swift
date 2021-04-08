//
//  AudioController.swift
//  Malugri
//
//  Created by Free App on 25/02/2021.
//  Copyright © 2021 freeappsw. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation
import MediaPlayer


//MARK: - Helper structures

enum MGError: Error {
    case ifstreamError(code: Int32), brstmReadError(code: UInt8, description: String)
}

struct MGFileInformation {
    public let fileType: String, codecCode: UInt32, codecString: String,
    sampleRate: UInt, looping: Bool, duration: Int,
    channelCount, totalSamples, loopPoint, blockSize, totalBlocks: UInt;
}

// MARK: - Main player class

class MalugriPlayer {
    public var backend: MGAudioBackend;
    public var currentFile: String? = nil;
    public var fileInformation: MGFileInformation {
        get {
            return MGFileInformation(fileType: MalugriUtil.resolveAudioFormat(UInt(gFileType())),
                                     codecCode: gFileCodec(),
                                     codecString: MalugriUtil.resolveAudioCodec(UInt(gFileCodec())),
                                     sampleRate: gHEAD1_sample_rate(), looping: gHEAD1_loop() == 1,
                                     duration: Int(floor(Double(gHEAD1_total_samples()) / Double(gHEAD1_sample_rate()))),
                                     channelCount: UInt(gHEAD3_num_channels(0)),
                                     totalSamples: gHEAD1_total_samples(),
                                     loopPoint: gHEAD1_loop_start(),
                                     blockSize: gHEAD1_blocks_samples(),
                                     totalBlocks: gHEAD1_total_blocks())
        }
    }
    public func loadFile(file: String) throws {
        initStruct();
        self.currentFile = file;
        let pointer: UnsafePointer<Int8>? = NSString(string: file).utf8String;
        let status = createIFSTREAMObject(strdup(pointer));
        if (status != 1) {
            throw MGError.ifstreamError(code: status);
        }
        let status2 = readFstreamBrstm();
        if (status2 > 127) {
            throw MGError.brstmReadError(code: status2, description: MalugriUtil.brstmReadErrorCode[status2] ?? "Unknown error");
        }
        backend.initialize(format: self.fileInformation);
    }
    public init (using backend: MGAudioBackend) {
        self.backend = backend;
    }
    public func closeFile() {
        closeBrstm();
        self.currentFile = nil;
    }
    public func fullyDecode() -> UnsafeMutablePointer<UnsafeMutablePointer<Int16>?>? {
        let file = FileHandle.init(forReadingAtPath: self.currentFile!)!.availableData;
        _ = file.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) -> Bool in
            readABrstm(u8Ptr, 1, true);
            return true;
        }
        return gPCM_samples();
    }
}

protocol MGAudioBackend {
    var currentSampleNumber: UInt { get set };
    func initialize (format: MGFileInformation) -> Void;
    func resume() -> Void;
    func pause() -> Void;
    func stop() -> Void;
    var state: Bool { get }; // true when playing, false when not;
    var needsLoop: Bool { get set}; // Sets automatically to true or false depending on file loop flag and can be explicitly changed
    func play() -> Void; //Assuming the api can get the samples from gPCM_buffer or using the getbuffer / getBufferBlock function
}
