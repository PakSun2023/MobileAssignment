//
//  AudioView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 27/6/2023.
//
// reference: https://github.com/wan-dada/swift-swiftui-example/blob/main/hello/API/api_RecordSound.swift

import SwiftUI
import Foundation
import AVFoundation

enum RecordStatus {
    case noStart
    case start
    case end
}

struct AudioView: View {
    var chat: Chat
    let sendAudio: () -> ()
    
    let recoder_manager = RecordManager()
    
    @State var duration: Double = 0
    @State var status: RecordStatus = .noStart
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack {
                
                HStack {
                    Image(systemName: "waveform.path")
                    Text("\(duration) Seconds")
                }
                .offset(y: -40)
                
                if status == .noStart {
                    Button(action: {
                        recoder_manager.beginRecord()
                        status = .start
                    }, label: {
                        RecordButton(iconName: "mic.fill")
                    })
                }
                
                if status == .start {
                    Button(action: {
                        duration = recoder_manager.stopRecord()
                        status = .end
                    }, label: {
                        RecordButton(iconName: "waveform.and.mic")
                    })
                }
                
                if status == .end {
                    HStack(spacing: 100) {
                        Button(action: {
                            recoder_manager.play()
                        }, label: {
                            RecordButton(iconName: "play.circle")
                        })
                        
                        Button(action: {
                            status = .noStart
                        }, label: {
                            RecordButton(iconName: "xmark.circle")
                        })
                    }
                }
                
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                    .font(.callout)
                    .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("send", role: .destructive) {
                        sendAudio()
                    }
                    .font(.callout)
                    .foregroundColor(.black)
                    .opacity(status != .end ? 0.5 : 1)
                    .disabled(status != .end || duration == 0)
                }
            }
        }
    }
}

struct RecordButton: View {
    @State var iconName = ""
    var body: some View {
        Image(systemName: iconName)
            .font(.largeTitle)
            .imageScale(.large)
    }
}

class RecordManager {
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    let file_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/record2023.wav")
    
    func beginRecord() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let err{
            print("set type fail:\(err.localizedDescription)")
        }
        
        do {
            try session.setActive(true)
        } catch let err {
            print("init:\(err.localizedDescription)")
        }
        
        let recordSetting: [String: Any] = [
            AVSampleRateKey: NSNumber(value: 16000),
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: NSNumber(value: 16),
            AVNumberOfChannelsKey: NSNumber(value: 1),
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)
        ];
        
        do {
            let url = URL(fileURLWithPath: file_path!)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            recorder!.record()
            print("start recording")
        } catch let err {
            print("record fail:\(err.localizedDescription)")
        }
    }
    
    func stopRecord() -> Double {
        var duration: Double = 0
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("record saved to：\(file_path!)")
            }
            recorder.stop()
            self.recorder = nil
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file_path!))
            duration = player!.duration
        } catch {}
        return duration
    }
    
    func play() {
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file_path!))
            player!.play()
        } catch let err {
            print("Play error:\(err.localizedDescription)")
        }
    }
}
