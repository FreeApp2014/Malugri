//
// Created by admin on 2020-01-28.
// Copyright (c) 2020 FreeAppSW. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

var needLoop = true;
var loopBuffer: AVAudioPCMBuffer = AVAudioPCMBuffer();

class AudioManager:NSObject {

    let audioPlayerNode = AVAudioPlayerNode()

    lazy var audioEngine: AVAudioEngine = {
        let engine = AVAudioEngine()

        // Must happen only once.
        engine.attach(self.audioPlayerNode)

        return engine
    }()
    var needsToPlay: Bool = true;
    var wasUsed: Bool = false;

    //TODO: Looping and on demand decoding
    func initialize(format: AVAudioFormat) -> Void {
        do {
            print(format);
            self.audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: format);
            try self.audioEngine.start();
        } catch {
            let alert = NSAlert();
            alert.messageText = "Failed to start audio engine";
            alert.alertStyle = .critical;
            alert.runModal();
        }
    }
    var loopCount = 0;
    var needsLoop = true;
    var i: Double = 0;
    let playerThread = DispatchQueue.global(qos: .userInteractive);
    var e: Int64 = 0;
    var pausedSampleNumber: Int64 = 0;
    var releasedSampleNumber: Int64 = 0;
    var tsToReturn = false;
    
    func getCurrentSampleNumber() -> Int64{
        return self.audioPlayerNode.lastRenderTime!.sampleTime - releasedSampleNumber + pausedSampleNumber;
    }
    
    func playBuffer(buffer: AVAudioPCMBuffer) -> Void {
        wasUsed = true;
        
        playerThread.async{
            self.needsToPlay = true;
            if (decodeMode == 1) {
                self.loopCount += 1;
                if (self.loopCount > gHEAD1_total_blocks()){
                    self.loopCount = 1;
                    self.releasedSampleNumber = self.audioPlayerNode.lastRenderTime!.sampleTime - Int64(gHEAD1_loop_start());
                }
                loopBuffer = self.getNextChunk();
            }
            self.audioPlayerNode.play();
            if (self.getCurrentSampleNumber() < 0) {
                self.releasedSampleNumber -=  self.getCurrentSampleNumber();
            }
            self.pausedSampleNumber = 0;
            self.audioPlayerNode.scheduleBuffer(buffer,  completionHandler: {
                if (decodeMode == 0) {self.releasedSampleNumber = self.audioPlayerNode.lastRenderTime!.sampleTime - Int64(gHEAD1_loop_start());}
                self.needsToPlay = false;
                print("CH");
                if (self.needsLoop){
                    print("Loop");
                    if (decodeMode == 0) {self.loopCount += 1;}
                    self.playBuffer(buffer: loopBuffer);
                } else {
                    closeBrstm();
                }
            });
            while (self.needsToPlay){
                if (self.audioPlayerNode.isPlaying) {
                    self.e = self.getCurrentSampleNumber();
                    self.i =  Double(self.e) / Double(gHEAD1_sample_rate());
                }
                Thread.sleep(forTimeInterval: 0.001);
            };
            print("A");
        };
    }
    func state() -> Bool {
        return self.audioPlayerNode.isPlaying;
    }
    func varPlay() -> Bool {
        return self.needsToPlay;
    }
    func resume() -> Void {
        self.playerThread.resume();
        do { try self.audioEngine.start();} catch {print("err")}
        self.audioPlayerNode.play(at: nil);
        self.releasedSampleNumber = self.audioPlayerNode.lastRenderTime!.sampleTime;
        print(pausedSampleNumber);
        print(releasedSampleNumber);
    }
    
    func pause() -> Void {
        self.pausedSampleNumber = self.getCurrentSampleNumber()
        self.audioPlayerNode.pause();
        self.audioEngine.pause();
        self.playerThread.suspend();
    }
    func stopBtn() -> Void {
        needsLoop = false;
        wasUsed = false;
        stop();
    }
    func stop() -> Void {
        self.releasedSampleNumber = self.audioPlayerNode.lastRenderTime!.sampleTime;
        self.needsToPlay = false;
        self.audioPlayerNode.stop();
        self.audioPlayerNode.reset();
        self.audioEngine.reset();
        self.initialize(format: format);
    }
    func genPB(){
        loopBuffer = createAudioBuffer(gPCM_samples(), offset: Int(gHEAD1_loop_start()), needToInitFormat: false);
    }
    func getNextChunk() -> AVAudioPCMBuffer {
        let bufferblock = getBufferBlock(gHEAD1_blocks_samples() * UInt(loopCount));
        return createBlockBuffer(bufferblock!, needToInitFormat: false);
    }
}
