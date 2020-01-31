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
    var needsLoop = true;
    var i: Double = 0;
    func playBuffer(buffer: AVAudioPCMBuffer) -> Void {
        needsLoop = true;
        let newThread = DispatchQueue.global(qos: .userInitiated);
        newThread.async{
            self.needsToPlay = true;
            self.audioPlayerNode.play();
            self.audioPlayerNode.scheduleBuffer(buffer, completionHandler: {
                self.needsToPlay = false;
                Thread.sleep(forTimeInterval: 0.005);
                print("CH");
                if (self.needsLoop){
                    print("Loop");
                    self.i = ceil(Double(gHEAD1_loop_start()) / Double(gHEAD1_sample_rate()));
                    self.audioPlayerNode.reset();
                    self.audioEngine.reset();
                    self.initialize(format: format);
                    self.playBuffer(buffer: loopBuffer);
                } else {
                    closeBrstm();
                }
            });
            while (self.needsToPlay){
                if (self.audioPlayerNode.isPlaying) {self.i += 0.005;}
                Thread.sleep(forTimeInterval: 0.005);
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
        self.audioPlayerNode.play();
    }
    func pause() -> Void {
        self.audioPlayerNode.pause();
    }
    func stopBtn() -> Void {
        needsLoop = false;
        stop();
    }
    func stop() -> Void {
        self.needsToPlay = false;
        self.audioPlayerNode.reset();
        self.audioEngine.reset();
    }
    func genPB(){
        loopBuffer = createAudioBuffer(offset: Int(gHEAD1_loop_start()), needToInitFormat: false);
    }
}