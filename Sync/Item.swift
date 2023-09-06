//
//  Item.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/16.
//

import Foundation


struct Item: Identifiable, Codable {
    var id = UUID()
    var title: String
}
