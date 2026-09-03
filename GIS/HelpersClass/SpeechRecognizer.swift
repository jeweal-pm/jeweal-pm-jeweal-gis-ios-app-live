//
//  SpeechRecognizer.swift
//  GIS
//
//  Created by Sumit Kumar Meena on 07/02/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizer {
    private let speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init(localeIdentifier: String = "en-US") {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)) else {
            fatalError("Speech recognizer is not available for the specified locale: \(localeIdentifier)")
        }
        speechRecognizer = recognizer
    }
    
    func startRecognition(completion: @escaping (String?) -> Void) {
        first = true
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            startRecognitionInternal(completion: completion)
        case .denied, .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.startRecognitionInternal(completion: completion)
                } else {
                    completion(nil)
                }
            }
        @unknown default:
            completion(nil)
        }
    }
    
    func startRecognitionInternal(completion: @escaping (String?) -> Void) {
        guard speechRecognizer.isAvailable else {
            completion(nil)
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            completion(nil)
            return
        }
        startTimer()
        guard let finalrecognitionRequest = recognitionRequest else {
            completion(nil)
            return
        }
        recognitionTask = speechRecognizer.recognitionTask(with: finalrecognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            updateTimer()
            
            if let result = result , result.isFinal {
                let transcription = result.bestTranscription.formattedString
                stopRecognition()
                completion(transcription)
            } else if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                stopRecognition()
                completion(nil)
            }
        }
    }
    private var timer: Timer?
    private var first = true
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: first ? 4.0 : 2.0, repeats: false) { [weak self] _ in
            self?.stopRecognition()

        }
        first = false
    }

    private func updateTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.finish()
    }
}
