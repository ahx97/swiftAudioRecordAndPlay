//
//  RecordViewController.swift
//  audioPlayAndRecord
//
//  Created by Aaron Henry on 10/30/19.
//  Copyright © 2019 Aaron Henry. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate{
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var statusLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isEnabled = false;
        recordButton.isEnabled = false;

        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                        self.recordButton.action = #selector(self.recordTapped)
                        self.recordButton.isEnabled = true
                        self.playButton.isEnabled = true
                        self.statusLabel.text = "Record"
                        
                    } else {
                        print("failed to record")
                        self.playButton.isEnabled = false
                        self.statusLabel.text = "Fail"
                        // failed to record!
                    }
                }
            }
        } catch {
            print("failed to record")
            playButton.isEnabled = false
            statusLabel.text = "fail"
            // failed to record!
        }
        
        
    }
    
    func startRecording() {
        playButton.isEnabled = false
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("audio.m4a")
        
        let audioURL = getAudioURL()
           print(audioURL.absoluteString)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.image = UIImage(named: "StopButton")
            
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
  

    func finishRecording(success: Bool) {
        playButton.isEnabled = true
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            recordButton.image = UIImage(named: "RecordButton")
            statusLabel.text = "Finish"
            
        } else {
            print("error here on finishing")
            recordButton.isEnabled = false
            statusLabel.text = "FF"
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    /*
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
*/
    func getAudioURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("audio.m4a")
    }
    
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        
        let url = getAudioURL()
        

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // couldn't load file :(
        }
        
        
        
        /*
        if Bundle.main.path(forResource: "audio.m4a", ofType: nil) != nil {
            print("Continue processing")
        } else {
            print("Error: No file with specified name exists")
        }
        
        do {
            if let fileURL = Bundle.main.path(forResource: "audio.m4a", ofType: nil) {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        
        player?.play()
        */
    }
    
    
}
