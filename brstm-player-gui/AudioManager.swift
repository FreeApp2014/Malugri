//
// Created by admin on 2020-01-28.
// Copyright (c) 2020 FreeAppSW. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

var needLoop = true;

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
    func playBuffer(buffer: AVAudioPCMBuffer) -> Void {
        needsLoop = true;
        let newThread = DispatchQueue.global(qos: .userInitiated);
        newThread.async{
            self.needsToPlay = true;
            self.audioPlayerNode.play();
            self.audioPlayerNode.scheduleBuffer(buffer, completionHandler: {
                //self.needsToPlay = false;
            });
            while (self.needsToPlay){
                Thread.sleep(forTimeInterval: 0.1);
            };
            print("A");
            self.audioPlayerNode.reset();
            self.audioEngine.reset();
            if (self.needsLoop){
                self.playBuffer(buffer: createAudioBuffer(offset: Int(gHEAD1_loop_start()), needToInitFormat: false))
            } else {
                closeBrstm()
            }
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
    }
}