//
//  RecordHelper.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/21.
//

import Foundation
import AVFoundation
import CoreData
import UIKit

enum AudioSessionMode {
    case record
    case pause
    case play
}

class RecordHelper: NSObject, AVAudioRecorderDelegate{
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var isAudioRecordingGranted = false     //whether is permit recording
    var isRecording = false     // whether is recording
    var finish = true           // whether record is finished
    var playList:[Record] = []
    //set recorded quality
    var recordSettings:[String:Any] = [
        AVEncoderAudioQualityKey:AVAudioQuality.min.rawValue,
        AVEncoderBitRateKey:16,
        AVNumberOfChannelsKey:1,
        AVSampleRateKey:44100.0
    ]
    
    let audioSession = AVAudioSession.sharedInstance()
    let context = CoreDataHelper.shared.managedObjectContext()
    
    func recordpermission() {
            
        switch audioSession.recordPermission {
            case .granted:
                isAudioRecordingGranted = true
                break
            case .denied:
                isAudioRecordingGranted = false
                break
            default:
                audioSession.requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                })
                break
            }
        }
    
    //set recording mode
    func settingAudioSession(toMode mode:AudioSessionMode){
       
        do{
            switch mode {
            case .record:
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            default:
                try audioSession.setCategory(AVAudioSession.Category.playback)
            }
            try audioSession.setActive(true) //why false?
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //start Recording
    func startRecording() {
        
        if isRecording == true {
            return
        }
        
        //set stored path
        let fileName = "MyAudio_\(Date().date2String(dateFormat: "yyyy-MM-dd_HH:mm:ss")).m4a"
        let url = getAudioPath(fileName: fileName)
        do{
            audioRecorder = try AVAudioRecorder(url: url, settings: self.recordSettings)
            audioRecorder?.delegate = self
            
            //                let userDefault = UserDefaults.standard
            //                self.playList = userDefault.value(forKey: "MyPlayList") as? [String] ?? []
        }catch{
            print(error.localizedDescription)
        }
        
        //record
        settingAudioSession(toMode: .record)
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecording = true
        finish = false
        
    }
    
    //pause Recording
    func pauseRecording() {
        if isRecording {
            settingAudioSession(toMode: .pause)
            audioRecorder?.pause()
            isRecording = false
        }
    }
    
    //re-recording
    func resumeRecording() {
        settingAudioSession(toMode: .record)
        audioRecorder?.record()
        isRecording = true
        
    }
    
    //stop Recording
    func stopRecording() {
        if audioRecorder != nil {
            audioRecorder?.stop()
            isRecording = false
            settingAudioSession(toMode: .play)
        }
    }
    
    //finish Recording
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag == true {
           
            var title = ""
            
            let alertController = UIAlertController(title: "Save the audio", message: "Please enter a title.", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "Please enter a title."
            }
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
                if let titleField = alertController.textFields?[0]{
                    title = titleField.text ?? "MyAudio"
                    let context = CoreDataHelper.shared.managedObjectContext()
                    let record = NSEntityDescription.insertNewObject(forEntityName: "Record", into: context) as! Record
                    record.name = "\(title)"
                    record.time = "\(Date().date2String(dateFormat: "yyyy-MM-dd_HH:mm:ss"))"
                    record.length = "\(recorder.url.audioDuration()?.rounding(toDecimal: 2) ?? 0)"
                    record.memory = "\(recorder.url.fileSize().rounding(toDecimal: 2))"
                    record.savePath = (recorder.url.absoluteString as NSString).lastPathComponent
                    self.playList.append(record)
                    CoreDataHelper.shared.saveContext()
                }
                alertController.resignFirstResponder()
            }
            alertController.addAction(confirmAction)
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)

            
            

//            print(record.time)
//            print(record.length)
//            print(record.memory)

            
//            playList.append((recorder.url.absoluteString as NSString).lastPathComponent)
////            print((recorder.url.absoluteString as NSString).lastPathComponent)
////            print(recorder.url.absoluteString as NSString)
//            
//            let userDefault = UserDefaults.standard
//            userDefault.setValue(playList, forKey: "MyPlayList")
//            userDefault.synchronize()

        }
        finish = true
    }
    
    
    override init() {
        super.init()
        
        
    }
}

