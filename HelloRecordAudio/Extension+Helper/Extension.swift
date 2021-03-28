//
//  Extension.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2021/3/18.
//

import Foundation
import UIKit
import AVFoundation

extension URL {
    
    func audioDuration() -> CGFloat? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: self)
            return CGFloat(audioPlayer.duration)
        } catch {
            assertionFailure("Failed creating audio player: \(error).")
            return nil
        }
    }
    
    func getDuration() -> Double? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: self)
            return audioPlayer.duration
        } catch {
            assertionFailure("Failed creating audio player: \(error).")
            return nil
        }
    }
    
    
    func fileSize() -> Double {
        var fileSize: Double = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024))
        }
        return fileSize
    }
}

extension Double {
    func rounding(toDecimal decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
    
    func floor(toInteger integer: Int) -> Double {
        let integer = integer - 1
        let numberOfDigits = pow(10.0, Double(integer))
        return (self / numberOfDigits).rounded(.towardZero) * numberOfDigits
    }
}

extension CGFloat {
    func rounding(toDecimal decimal: Int) -> CGFloat {
        let numberOfDigits = pow(10.0, CGFloat(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}


extension Date {
    func date2String(dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let dateString = formatter.string(from: self)
        return dateString
    }
}

extension NSObject {
    func getAudioPath(fileName: String) -> URL {
        let path = NSHomeDirectory() + "/Documents/" + fileName
        let url = URL(fileURLWithPath: path)
        return url
    }
}

extension UIApplication {

    static func topViewController(base: UIViewController? = (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}
