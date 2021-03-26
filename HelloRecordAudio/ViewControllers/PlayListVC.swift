//
//  PlayListVC.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/23.
//

import UIKit
import AVFoundation
import CoreData

class PlayListVC: UIViewController, AVAudioPlayerDelegate{

    var playList:[Record] = []
    var playIndex = 0
    var player:AVPlayer?
    var playerItem: AVPlayerItem?
    var savePath:String?

    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playPage: UIView!
    
    @IBOutlet weak var playNPauseBtn: UIButton!
    
    @IBOutlet weak var playingSlider: UISlider!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var reminderTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.queryFromCoreData()
        tableView.reloadData()
    }
    
    //MARK: - CoreData
    func queryFromCoreData() {
        let context = CoreDataHelper.shared.managedObjectContext();
        let request = NSFetchRequest<Record>.init(entityName: "Record")
        
        context.performAndWait {
            do{
                self.playList = try context.fetch(request)
            }catch{
                print("error \(error)")
                self.playList = []
            }
        }
    }
    
    
    @IBAction func playNPauseBtnPressed(_ sender: UIButton) {
        
        sender.setImage(UIImage(systemName: "play.fill")?.withTintColor(.lightGray), for: UIControl.State.normal)
        sender.setImage(UIImage(systemName: "pause.fill")?.withTintColor(.lightGray), for: UIControl.State.selected)
        
        if sender.isSelected == false{
            
            let url = getAudioPath(fileName: self.savePath ?? "")
            do{
                print(url)
                player = AVPlayer(url: url)
                playerItem = AVPlayerItem(url: url)
                self.player?.replaceCurrentItem(with: playerItem)
//                //audioPlayer = try AVAudioPlayer(contentsOf: url)
//                //player?.delegate = self
                print(self.player)
                player?.play()
                
                sender.isSelected = true
            }catch{
                print(error.localizedDescription)
            }
        }else{
            player?.pause()
            sender.isSelected = false
        }
    }
    
    
    @IBAction func playNext(_ sender: UIButton) {
    }
    
    
    
    @IBAction func playPrevious(_ sender: UIButton){
    }
    
   
    func audioPlayerDidFinishPlaying(_ player: AVPlayer, successfully flag: Bool) {
        self.playNPauseBtn.isSelected = false
    }
    
    func playMusic(){
        if playIndex < playList.count {
            if playIndex < 0 {
                playIndex = playList.count - 1
            }
            currentTime()
            reminderTime()
        }else{
            playIndex = 0
            currentTime()
            reminderTime()

        }
    }
    
    //更新播放時間＆Slider Value
    func currentTime(){
        if let player = self.player {
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
                if player.currentItem?.status == .readyToPlay {
                    //已跑秒數
                    let currentTime = CMTimeGetSeconds(player.currentTime())
                    //進度條跟著currentTime更新
                    self.playingSlider.value = Float(currentTime)
                    //currentTimeLabel跟著currentTime變換更新
                    self.currentTimeLabel.text = self.formatConversion(time: currentTime)
                }
            })
        }
    }
    
    //更新歌曲總時間＆Slider Value
    func reminderTime(){
        if let duration = playerItem?.asset.duration{
            let seconds = CMTimeGetSeconds(duration)
            self.reminderTimeLabel.text = "-" + formatConversion(time: seconds)
            self.playingSlider.minimumValue = 0
            self.playingSlider.maximumValue = Float(seconds)
            self.playingSlider.isContinuous = true
        }
    }
    
    
    
    //秒數轉換
    func formatConversion(time: Double) -> String {
        let answer = Int(time).quotientAndRemainder(dividingBy: 60)
        let returnStr = String(answer.quotient) + ":" + String(format: "%.02d", answer.remainder)
        return returnStr
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func closePlayPage(_ sender: UIButton) {
        
        self.playPage.isHidden = true
        
    }
    
//    func popPlayPage(button: UIButton) {
//        if button.isSelected == false {
//            self.playPage.isHidden = true
//        }else if button.isSelected == true {
//            self.playPage.isHidden = false
//        }
//    }
    


}

extension PlayListVC: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! CustomTableViewCell
        //cell.delegate = self
        
        
        cell.nameLabel.text = self.playList[indexPath.row].name
        
        if let name = self.playList[indexPath.row].name, let time = self.playList[indexPath.row].time,
           let length = self.playList[indexPath.row].length, let memory = self.playList[indexPath.row].memory{
            cell.detailLabel.text = "\(time)  \(length)秒  \(memory)KB"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let record = self.playList[indexPath.row]
            let context = CoreDataHelper.shared.managedObjectContext()
            context.performAndWait {
                context.delete(record)
            }
            CoreDataHelper.shared.saveContext()
            
            self.playList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.playPage.isHidden = false
        self.savePath = self.playList[indexPath.row].savePath
        //self.playIndex = indexPath.row
    }
}
