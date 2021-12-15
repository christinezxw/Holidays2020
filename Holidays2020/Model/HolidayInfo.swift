//
//  HolidayInfo.swift
//  Holidays2020
//
//  Created by Xuanwei Zhang on 12/14/21.
//

import Foundation
import RealmSwift

class HolidayInfo : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var date : String = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
