////
////  BtoWViewController.swift
////  brstm-player-gui
////
////  Created by Free App on 07/06/2020.
////  Copyright © 2020 FreeAppSW. All rights reserved.
////
//
//import Cocoa
//import AVFoundation
//import Foundation
//
//class BtoWViewController: NSViewController {
//
//    @IBOutlet weak var sourceFileLabel: NSTextField!
//    @IBOutlet weak var outputFileLabel: NSTextField!
//    @IBOutlet weak var statusLoader: NSProgressIndicator!
//    @IBOutlet weak var statusLabel: NSTextField!
//    var outputFileName: String = "", inputFileName: URL;
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do view setup here.
//    }
//    
//    private func doConversion(in sourceFile: String, out outFile: String) {
//        if(ViewController.readFile(path: sourceFile, convert: true)){
//            let buffer = createAudioBuffer(gPCM_samples(), offset: 0, needToInitFormat: true, format16: true);
//            do { let outputFile = try AVAudioFile.init(forWriting: outFile, settings: [AVFormatIDKey:kAudioFormatLinearPCM,
//                    AVLinearPCMBitDepthKey: 16,
//                    AVLinearPCMIsFloatKey: false,
//                    //  AVLinearPCMIsBigEndianKey: false,
//                    AVSampleRateKey: gHEAD1_sample_rate(),
//                    AVNumberOfChannelsKey: gHEAD3_num_channels() > 2 ? 2 : gHEAD3_num_channels()
//                ] as [String : Any], commonFormat: .pcmFormatInt16, interleaved: false);
//                try outputFile.write(from: buffer);
//            } catch {
//                print("Error");
//            }
//        }
//    }
//}
