//
//  PlayListVC.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/23.
//

import UIKit
import AVFoundation
import CoreData
import Social

class PlayListVC: UIViewController, AVAudioPlayerDelegate, CustomTableViewCellDelegate{


    var playList:[Record] = []
    var playIndex = 0
    var player: AVPlayer?
    var playerItem: AVPlayerItem?

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playPage: UIView!
    
    @IBOutlet weak var playNPauseBtn: UIButton!
    
    @IBOutlet weak var playingSlider: UISlider!
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var reminderTimeLabel: UILabel!

    @IBOutlet weak var audioName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.queryFromCoreData()
        tableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.queryFromCoreData()
        tableView.reloadData()
        
        playNPauseBtn.setImage(UIImage(systemName: "play.fill")?.withTintColor(.systemGray6), for: UIControl.State.normal)
        playNPauseBtn.setImage(UIImage(systemName: "pause.fill")?.withTintColor(.systemGray6), for: UIControl.State.selected)
        
    }
    
    @IBAction func playNPauseBtnPressed(_ sender: UIButton) {
        
        if sender.isSelected == false{
            if playingSlider.value == 0 {
                
                let fileName = self.playList[playIndex].savePath
                let url = getAudioPath(fileName: fileName ?? "")
                print(url)
                print(fileName)
                self.player = AVPlayer()
                print(self.player)
                self.playerItem = AVPlayerItem(url: url)
                print(self.playerItem)
                self.player?.replaceCurrentItem(with: playerItem)
                player?.play()
                updateTime()
                sender.isSelected = true
                
            }else if playingSlider.value != 0 {
                
                let seconds = Int64(playingSlider.value)
//                let interval: CMTime = CMTimeMakeWithSeconds(Double(seconds)*1000000, preferredTimescale: Int32(NSEC_PER_SEC))
                let targetTime = CMTimeMake(value: seconds*Int64(NSEC_PER_SEC), timescale: Int32(NSEC_PER_SEC))
                player?.seek(to: targetTime)
                player?.play()
                updateTime()
                sender.isSelected = true
                
            }
        }else{
            player?.pause()
            sender.isSelected = false
            updateTime()
        }
    }
    
    @IBAction func playNext(_ sender: UIButton) {

        self.tableView.deselectRow(at: IndexPath(row: playIndex, section: 0), animated: true)
        playIndex = playIndex + 1
        playPreviousOrNext()

    }
    
    @IBAction func playPrevious(_ sender: UIButton){

        self.tableView.deselectRow(at: IndexPath(row: playIndex, section: 0), animated: true)
        playIndex = playIndex - 1
        playPreviousOrNext()

    }
    
    func playPreviousOrNext(){

        if playIndex < playList.count {
            if playIndex < 0 {
                playIndex = playList.count - 1
            }
            self.tableView.selectRow(at: IndexPath(row: playIndex, section: 0), animated: true, scrollPosition: .none)
            self.audioName.text = self.playList[playIndex].name
            
            let fileName = self.playList[playIndex].savePath ?? ""
            let url = getAudioPath(fileName: fileName)
            //self.player = AVPlayer()
            self.playerItem = AVPlayerItem(url: url)
            self.player?.replaceCurrentItem(with: playerItem)
            self.player?.play()
            self.playNPauseBtn.isSelected = true

            updateTime()
        }else{
            playIndex = 0
            self.tableView.selectRow(at: IndexPath(row: playIndex, section: 0), animated: true, scrollPosition: .none)
            self.audioName.text = self.playList[playIndex].name
            
            let fileName = self.playList[playIndex].savePath ?? ""
            let url = getAudioPath(fileName: fileName)
            //print(url)
            //self.player = AVPlayer()
            self.playerItem = AVPlayerItem(url: url)
            self.player?.replaceCurrentItem(with: playerItem)
            self.player?.play()
            self.playNPauseBtn.isSelected = true

            updateTime()
        }
    }
    
    func restartAll(){
        let fileName = self.playList[playIndex].savePath
        let url = getAudioPath(fileName: fileName ?? "")
        //self.player = AVPlayer()
        self.playerItem = AVPlayerItem(url: url)
        self.player?.replaceCurrentItem(with: playerItem)
        player?.play()
        updateTime()
        self.playNPauseBtn.isSelected = true
    }
    
    //拖曳Slider進度，要設定player播放軌道
    @IBAction func playbackChangeSlider(_ sender: UISlider) {
        //Slider移動的位置
        let seconds = Int64(sender.value)
        //計算秒數
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        //設定player播放進度
        player?.seek(to: targetTime)
        
        //如果player暫停，則繼續播放
        if player?.rate == 0 {
            player?.play()
        }
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
        let volume = sender.value
        player?.volume = volume
    }
    
    @IBAction func closePlayPage(_ sender: UIButton) {
        if player?.rate == 1 {
            player?.pause()
        }
        self.playNPauseBtn.isSelected = false
        self.playPage.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if player?.rate == 1 {
            player?.pause()
        }
        self.playNPauseBtn.isSelected = false
        self.playPage.isHidden = true
    }
    
}

//MARK: - 畫面相關function
extension PlayListVC{
    
    //更新播放時間＆Slider Value
    func updateTime(){
        
        if let duration = playerItem?.asset.duration{
            let seconds = CMTimeGetSeconds(duration)
            self.reminderTimeLabel.text = "-" + formatConversion(time: seconds)
            self.playingSlider.minimumValue = 0
            self.playingSlider.maximumValue = Float(seconds)
            self.playingSlider.isContinuous = true
        }
        
        guard let player = self.player else { return }
        
        let interval: CMTime = CMTimeMakeWithSeconds(0.001, preferredTimescale: Int32(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (CMTime) in
            if self.player?.currentItem?.status == .readyToPlay {
                //已跑秒數
                let currentTime = CMTimeGetSeconds(self.player?.currentTime() ?? CMTime)
                print(currentTime)
                //進度條跟著currentTime更新
                self.playingSlider.value = Float(currentTime)
                //currentTimeLabel跟著currentTime變換更新
                self.currentTimeLabel.text = self.formatConversion(time: currentTime)
                
                if let duration = self.playerItem?.asset.duration{
                    let seconds = CMTimeGetSeconds(duration)
                    let reminderTime = seconds - currentTime
                    self.reminderTimeLabel.text = "-" + self.formatConversion(time: reminderTime)
                    
                    if self.playingSlider.value == Float(seconds) {
                        self.playingSlider.value = 0
                        self.currentTimeLabel.text = "0:00"
                        self.reminderTimeLabel.text = "-" + self.formatConversion(time: seconds)
                        self.playNPauseBtn.isSelected = false
                    }
                }
            }
        })
    }
    
    //跳出編輯頁面
    func popEditingAlert(indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: nil, message: "I want to...", preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "Share with friends", style: .default) { (action) in
            
            let record = self.playList[indexPath.row]
            let activityItem = self.getAudioPath(fileName: record.savePath ?? "")
//            print(record.savePath)
//            print(activityItem)
            let activityVC = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
            activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                // 如果錯誤存在，跳出錯誤視窗並顯示給使用者。
                if error != nil {
                    let errorAlertController = UIAlertController(title: "Error", message: "Error:\(error!.localizedDescription)", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                        errorAlertController.resignFirstResponder()
                    }
                    errorAlertController.addAction(cancelAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                    return
                }
                                                     
                // 如果發送成功，跳出提示視窗顯示成功。
                if completed {
                    let successAlertController = UIAlertController(title: "Success", message: "Already share this file.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                        successAlertController.resignFirstResponder()
                    }
                    successAlertController.addAction(okAction)
                    self.present(successAlertController, animated: true, completion: nil)
                }
            }

            self.present(activityVC, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.resignFirstResponder()
        }
        let deleteAction = UIAlertAction(title: "Delete the file", style: .destructive) { (action) in
            let deleteAlertController = UIAlertController(title: "Do you want to delete this file?", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                
                let record = self.playList[indexPath.row]
                let context = CoreDataHelper.shared.managedObjectContext()
                context.performAndWait {
                    context.delete(record)
                }
                CoreDataHelper.shared.saveContext()

                self.playList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                deleteAlertController.resignFirstResponder()
            }
            deleteAlertController.addAction(okAction)
            deleteAlertController.addAction(cancelAction)
            self.present(deleteAlertController, animated: true, completion: nil)

        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
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
        let record = self.playList[indexPath.row]
        if record.name == "" {
            cell.nameLabel.text = "MyAudio"
        }else{
            cell.nameLabel.text = record.name
        }
        
        if let time = record.time,
           let length = record.length, let memory = record.memory{
            
            cell.detailLabel.text = "\(time)  \(length)  \(memory)KB"
        }
        cell.delegate = self
        cell.audioIndexPath = indexPath
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.playPage.isHidden = false
        self.playingSlider.value = 0
        self.playIndex = indexPath.row
        self.audioName.text = self.playList[self.playIndex].name
        self.currentTimeLabel.text = "0:00"
        
        if let fileName = self.playList[indexPath.row].savePath{
            let url = self.getAudioPath(fileName: fileName)
            let duration = url.getDuration()?.rounding(toDecimal: 2)
            print(duration)
            self.reminderTimeLabel.text = "-" + formatConversion(time: duration ?? 0)
        }
        self.restartAll()
    }
}

extension PlayListVC{
    
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
    
}

extension PlayListVC{
    
    //秒數轉換
    func formatConversion(time: Double) -> String {
        let answer = Int(time).quotientAndRemainder(dividingBy: 60)
        let returnStr = String(answer.quotient) + ":" + String(format: "%.02d", answer.remainder)
        return returnStr
    }
}
