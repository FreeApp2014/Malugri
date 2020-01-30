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
    func playBuffer(buffer: AVAudioPCMBuffer) -> Void {
        let newThread = DispatchQueue.global(qos: .userInitiated);
        newThread.async{
            self.audioPlayerNode.play();
            self.audioPlayerNode.scheduleBuffer(buffer);
            Thread.sleep(forTimeInterval: Double(gwritten_samples()/2) / Double(gHEAD1_sample_rate()));
            self.audioPlayerNode.reset();
            self.audioEngine.reset();
            closeBrstm();
        };
    }
    func state() -> Bool {
        return self.audioPlayerNode.isPlaying;
    }
    func resume() -> Void {
        self.audioPlayerNode.play();
    }
    func pause() -> Void {
        self.audioPlayerNode.pause();
    }
    func stop() -> Void {
        self.audioPlayerNode.stop();
        self.audioPlayerNode.reset();
        self.audioEngine.reset();
        closeBrstm();
    }
}