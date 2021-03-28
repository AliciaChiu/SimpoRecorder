//
//  SetVC.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2021/3/24.
//

import UIKit
import MessageUI

class SetVC: UIViewController {
    
    @IBOutlet weak var setTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor(red: 199/255, green: 193/255, blue: 184/255, alpha: 1)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SetVC: UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        if indexPath == IndexPath(row: 0, section: 0){
//            cell.textLabel?.text = "App Set"
//            cell.imageView?.image = UIImage(systemName: "gearshape.fill")?.withTintColor(UIColor(red: 82/255, green: 82/255, blue: 255/255, alpha: 1), renderingMode: .alwaysOriginal)
//        }else
        if indexPath == IndexPath(row: 0, section: 0){
            cell.textLabel?.text = "Contact Us"
            cell.imageView?.image = UIImage(systemName: "envelope.fill")?.withTintColor(UIColor(red: 53/255, green: 67/255, blue: 94/255, alpha: 1), renderingMode: .alwaysOriginal)
        }else if indexPath == IndexPath(row: 1, section: 0){
            cell.textLabel?.text = "Grade Us"
            cell.imageView?.image = UIImage(systemName: "star.fill")?.withTintColor(UIColor(red: 53/255, green: 67/255, blue: 94/255, alpha: 1), renderingMode: .alwaysOriginal)
        }else if indexPath == IndexPath(row: 2, section: 0){
            cell.textLabel?.text = "App Version: 1.0"
            cell.imageView?.image = UIImage(systemName: "house.fill")?.withTintColor(UIColor(red: 53/255, green: 67/255, blue: 94/255, alpha: 1), renderingMode: .alwaysOriginal)
            cell.accessoryType = .none
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath == IndexPath(row: 0, section: 0){
            if (MFMailComposeViewController.canSendMail()) {
                let alert = UIAlertController(title: "", message: "Do you have any question? Welcome to contact us😊", preferredStyle: .alert)
                let email = UIAlertAction(title: "Email", style: .default) { (action) in
                    
                    let mailController = MFMailComposeViewController()
                    mailController.mailComposeDelegate = self
                    mailController.title = "I have some question."
                    mailController.setSubject("SimpleRecorder- I have some suggestion.")
                    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                    //let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                    let messageBody = "<br/><br/><br/>Product:SimpoRecorder(V\(version!))"
                    mailController.setMessageBody(messageBody, isHTML: true)
                    mailController.setToRecipients(["simplerecorder110@gmail.com"])
                    self.present(mailController, animated: true, completion: nil)
                    
                }
                let cancelAction = UIAlertAction(title: "not now", style: .cancel) {_ in
                    alert.resignFirstResponder()
                }
                alert.addAction(email)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Can't send the mail.")
            }
        }else if indexPath == IndexPath(row: 1, section: 0){
            let askController = UIAlertController(title: "Hello User", message: "If you like this app, please rate in App Store. Thanks.😊", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "I want to rate", style: .default) { (action) in
                //let appID = "1560110307"
                let appURL = URL(string: "https://apps.apple.com/us/app/simporecorder/id1560110307")!
                UIApplication.shared.open(appURL, options: [:]) { (success) in
                    //
                }
            }
            let laterAction = UIAlertAction(title: "Rate later", style: .default, handler: nil)
            askController.addAction(laterAction)
            askController.addAction(okAction)
            self.present(askController, animated: true, completion: nil)
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("user cancelled")
        case .failed:
            print("user failed")
        case .saved:
            print("user saved email")
        case .sent:
            print("email sent")
        default:
            print("user cancelled")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
}
