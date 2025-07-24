//
//  Item.swift
//  dearjohn
//
//  Created by Megan Donahue on 4/24/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
