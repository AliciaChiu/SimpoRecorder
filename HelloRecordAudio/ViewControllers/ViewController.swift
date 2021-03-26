//
//  ViewController.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/21.
//

import UIKit
import AVFoundation
import StoreKit


class ViewController: UIViewController {
    

    let recordHelper = RecordHelper()
   
    //time property
    var timer: Timer?

   
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // record image,is not recording
        recordButton.setImage(UIImage(named: "record"), for: UIControl.State.normal)
        
        // pause image,is recording
        recordButton.setImage(UIImage(named: "pause"), for: UIControl.State.selected)
    }
    
    @objc func updateCurrentTimeLabel(){
        if ((recordHelper.audioRecorder?.isRecording) != nil) {
            
            var currentTime = recordHelper.audioRecorder?.currentTime ?? 0
            currentTime = currentTime + 0.01
            let hr = Int((currentTime / 60) / 60)
            let min = Int(currentTime / 60)
            let sec = Int(currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            currentTimeLabel.text = totalTimeString 
        }
    }

    
    @IBAction func startOrPauseRecording(_ sender: UIButton) {
        if recordHelper.isRecording == false{
            if recordHelper.finish == false {
                recordHelper.resumeRecording()
            }else{
                recordHelper.startRecording()
            }
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCurrentTimeLabel), userInfo: nil, repeats: true)
            self.timer?.fire()
            recordButton.isSelected = true
        }else{
            recordHelper.pauseRecording()
            recordButton.isSelected = false
            self.timer?.invalidate()
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        
        recordHelper.stopRecording()
        self.timer?.invalidate()
        recordButton.isSelected = false
        self.currentTimeLabel.text = "00:00:00"
        
//        if #available( iOS 10.3,*){
//        SKStoreReviewController.requestReview()
//        }
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        
        recordHelper.audioRecorder?.deleteRecording()
        recordHelper.isRecording = false
        recordHelper.finish = true
        //recordHelper.settingAudioSession(toMode: .)
        self.timer?.invalidate()
        recordButton.isSelected = false
        self.currentTimeLabel.text = "00:00:00"
        
    }
    
}

