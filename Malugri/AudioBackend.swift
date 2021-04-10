//
//  AudioBackend.swift
//  malugri-mobile
//
//  Created by admin on 26/08/2020.
//  Copyright © 2020 FreeAppSW. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - Default EZAudio backend
class MGEZAudioBackend: NSObject, MGAudioBackend {

    // MARK: - Initialization
    var output: EZOutput? = nil;
    fileprivate let dataSource = DataSource();
    
    func initialize (format: MGFileInformation){
        self.output = EZOutput(dataSource: dataSource, inputFormat: AudioStreamBasicDescription(mSampleRate: Float64(format.sampleRate),
                                                                                                mFormatID: kAudioFormatLinearPCM,
                                                                                                mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
                                                                                                mBytesPerPacket: 4,
                                                                                                mFramesPerPacket: 1,
                                                                                                mBytesPerFrame: 4,
                                                                                                mChannelsPerFrame: 2,
                                                                                                mBitsPerChannel: 16,
                                                                                                mReserved: 0));
        var b: UInt32 = 4096; //Frame per slice value for the audio unit
        
        // Set frames per slice to 4096 to allow playback with locked screen
        
        EZAudioUtilities.checkResult(AudioUnitSetProperty(output!.outputAudioUnit,
                                                          kAudioUnitProperty_MaximumFramesPerSlice,
                                                          kAudioUnitScope_Global,
                                                          0,
                                                          &b,
                                                          UInt32(MemoryLayout.size(ofValue: b))),
                                     operation: "Failed to set maximum frames per slice on mixer node".cString(using: .utf8));
        pState = CurrentPlayingBrstm(chCount: gHEAD3_num_channels(0), lChId: gLChId(0), rChId: gHEAD3_num_channels(0) == 2 ? gRChId(0) : gLChId(0))
    }
    
    var needsLoop: Bool {
        get {
            return dataSource.needLoop;
        }
        set (a) {
            dataSource.needLoop = a;
        }
    }

    // MARK: - Getter functions
    
    var currentSampleNumber: UInt {
        get {
            return dataSource.counter;
        }
        set (a) {
            dataSource.counter = a;
        }
    }
    
    func play() -> Void {
        output!.startPlayback();
    }
    
    // MARK: - UI buttons
    var state: Bool {
        get {
            return output!.isPlaying;
        }
    }
    
    func resume() -> Void {
        output!.startPlayback();
    }
    
    func pause() -> Void {
        output!.stopPlayback();
    }
    func stop() -> Void {
        if (self.state) {output!.stopPlayback();}
        dataSource.counter = 0;
    }
    
    private var _ctN: UInt32 = 0;
    
    var currentTrack: UInt32 {
        get {
            return _ctN;
        }
        set (a) {
            _ctN = a;
            pState = CurrentPlayingBrstm(chCount: gHEAD3_num_channels(Int32(a)), lChId: gLChId(Int32(a)), rChId: gHEAD3_num_channels(Int32(a)) == 2 ? gRChId(Int32(a)) : gLChId(Int32(a)))
        }
    }
}

// MARK: - Data source

@objc fileprivate class DataSource: NSObject, EZOutputDataSource {
    
    public var counter: UInt = 0;
    public var needLoop: Bool = true;
    
    // MARK: - The data source callback function
    func output(_ output: EZOutput!,
                shouldFill audioBufferList: UnsafeMutablePointer<AudioBufferList>!,
                withNumberOfFrames frames: UInt32,
                timestamp: UnsafePointer<AudioTimeStamp>!) -> OSStatus {
        
        // Check whether the counter is on loop point
        if (counter >= gHEAD1_total_samples()) {
            if (needLoop) {
                counter = gHEAD1_loop_start();
            } else {
                output.stopPlayback();
                return noErr;
            }
        }
        // Check whether the file has less samples than requested so that the loop can be seamless. Only applies to looping situation.
        if (frames > gHEAD1_total_samples() - counter && needLoop){
            // Number of samples that can be read from the file before over-read
            let supportedNo = UInt32(gHEAD1_total_samples() - counter);
            
            // Start with filling the buffer with the remainder of the file
            var samples = getbuffer(counter, supportedNo);
            let audioBuffer: UnsafeMutablePointer<Int16> = audioBufferList[0].mBuffers.mData!.assumingMemoryBound(to: Int16.self);
            var i = 0, j = 0;
            while (i < (supportedNo)*2){
                audioBuffer[Int(i)] = samples![Int(pState.lChId)]![j];
                audioBuffer[Int(i)+1] = samples![Int(pState.rChId)]![j]
                i+=2;
                j+=1;
            }
            
            // Reset the counter to the loop point
            counter = gHEAD1_loop_start();
            
            // Fill the remainder of the buffer with new portion of the file
            samples = getbuffer(counter, frames - supportedNo);
            j = 0;
            while (i < frames*2){
                audioBuffer[Int(i)] = samples![Int(pState.lChId)]![j];
                audioBuffer[Int(i)+1] = samples![Int(pState.rChId)]![j]
                i+=2;
                j+=1;
            }
            // Correctly increment the counter
            counter += UInt(frames - supportedNo);
        } else { // Play normally (gets called most of the time)
            let samples = getbuffer(counter, frames);
            let audioBuffer: UnsafeMutablePointer<Int16> = audioBufferList[0].mBuffers.mData!.assumingMemoryBound(to: Int16.self);
            var i = 0, j = 0;
            while (i < frames*2){
                audioBuffer[Int(i)] = samples![Int(pState.lChId)]![j];
                audioBuffer[Int(i)+1] = samples![Int(pState.rChId)]![j]
                i+=2;
                j+=1;
            }
            counter += UInt(frames);
        }
        return noErr;
    }
    
}

// MARK: - The store for current track being played and channel layouts

fileprivate struct CurrentPlayingBrstm {
    var chCount, lChId, rChId: UInt32;
}

fileprivate var pState = CurrentPlayingBrstm(chCount: gHEAD3_num_channels(0), lChId: gLChId(0), rChId: gHEAD3_num_channels(0) == 2 ? gRChId(0) : gLChId(0))
