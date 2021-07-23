//
//  AudioRecorder.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/07/2021.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    static let share = AudioRecorder()
    private override init() {
        super.init()
        checkAudioPremission()
    }
}

extension AudioRecorder {
    // Kiểm tra quyền
    private func checkAudioPremission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                self.isAudioRecordingGranted = isAllowed
            }
        }
    }
    
    // Cài đặt bản ghi
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Lỗi khi cài đặt bản ghi âm thanh: ", error.localizedDescription)
            }
        }
    }
    
    // Bắt đầu ghi
    func startRecording(fileName: String) {
        // Lấy file name trong document
        let audioFileName = Document.share.getDocumentsURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        
        // Cấu hình cài đặt audio
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Lỗi khi tiến hành ghi âm thanh: ", error.localizedDescription)
            self.finishRecording()
        }
    }
    
    // Hoàn thành ghi
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
}
