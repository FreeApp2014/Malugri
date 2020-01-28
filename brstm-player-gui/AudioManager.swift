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
    func playToEnd(buffer: AVAudioPCMBuffer, format: AVAudioFormat) -> Void{
        print(format, buffer);
        do {
            audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: format);
            try audioEngine.start();
        } catch {
            let alert = NSAlert();
            alert.messageText = "Failed to start audio engine";
            alert.alertStyle = .critical;
            alert.runModal();
        }
        let newThread = DispatchQueue.global(qos: .userInitiated);
        newThread.async{
            self.audioPlayerNode.play();
            self.audioPlayerNode.scheduleBuffer(buffer);
            Thread.sleep(forTimeInterval: Double(Int(gawritten_samples()/2) * Int(gaHEAD1_sample_rate())));

        };
    }
}