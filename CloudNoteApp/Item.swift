//
//  Item.swift
//  CloudNoteApp
//
//  Created by Julian Beck on 02.01.24.
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
