//
//  Activity.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/15.
//



import SwiftUI
import Foundation

struct Database: Identifiable {
    let id = UUID()
    let date: String
    let calories: String
    let steps: String
    let image: String
    let color: Color
}
