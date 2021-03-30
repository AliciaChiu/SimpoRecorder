//
//  ViewController.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/21.
//

import UIKit
import AVFoundation
import StoreKit
import AVKit


class ViewController: UIViewController {
    

    let recordHelper = RecordHelper()
   
    //time property
    var timer: Timer?

   
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var animationImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // record image,is not recording
        recordButton.setImage(UIImage(named: "record"), for: UIControl.State.normal)
        
        // pause image,is recording
        recordButton.setImage(UIImage(named: "pause_1"), for: UIControl.State.selected)
        
        recordButton.isSelected = false
    }
   
    @IBAction func startOrPauseRecording(_ sender: UIButton) {
        
        if recordHelper.isRecording == false{
            if recordHelper.finish == false {
                recordHelper.resumeRecording()
                recordButton.isSelected = true
            }else{
                recordHelper.startRecording()
                recordButton.isSelected = true
            }
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCurrentTimeLabel), userInfo: nil, repeats: true)
            self.timer?.fire()
            setupView()
            
        }else{
            recordHelper.pauseRecording()
            recordButton.isSelected = false
            self.timer?.invalidate()
            setupView()
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        
        recordHelper.stopRecording()
        self.timer?.invalidate()
        recordButton.isSelected = false
        self.currentTimeLabel.text = "00:00:00"
        setupView()
        
//        if #available( iOS 10.3,*){
//        SKStoreReviewController.requestReview()
//        }
    }
    
    @IBAction func refresh(_ sender: UIButton) {
//        recordHelper.audioRecorder?.stop()
//        if recordHelper.audioRecorder?.deleteRecording() == true{
//            recordHelper.isRecording = false
//            recordHelper.finish = true
//            self.timer?.invalidate()
//            recordButton.isSelected = false
//            self.currentTimeLabel.text = "00:00:00"
//            setupView()
//        }else{
//            print("delete xx")
//        }
//
        recordHelper.deleteRecord()
        recordHelper.isRecording = false
        recordHelper.finish = true
        self.timer?.invalidate()
        recordButton.isSelected = false
        self.currentTimeLabel.text = "00:00:00"
        setupView()
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
    
    private func setupView(){
   
        var images = [UIImage]()
        for i in 1...19 {
            images.append(UIImage(named: "iconImage\(i)")!)
        }
        animationImageView.animationImages = images
        animationImageView.animationDuration = 0.0
        animationImageView.animationRepeatCount = 0
        animationImageView.image = images.last
        
        if self.recordButton.isSelected == true {
            animationImageView.startAnimating()
        }else if self.recordButton.isSelected == true || self.currentTimeLabel.text == "00:00:00"{
            animationImageView.stopAnimating()
        }
    }
}

