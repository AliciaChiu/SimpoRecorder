//
//  Record.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2021/3/18.
//

import Foundation
import CoreData

class Record: NSManagedObject {
    
    @NSManaged var recordID: String?
    
    @NSManaged var name: String?
    
    @NSManaged var time: String?
    
    @NSManaged var length: String?
    
    @NSManaged var memory: String?
    
    @NSManaged var savePath: String?
    
    
    
    
    override func awakeFromInsert() {
        self.recordID = UUID().uuidString
    }
}
