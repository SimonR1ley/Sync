//
//  Activity.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/15.
//



import SwiftUI
import Foundation

struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let amount: String
    let image: String
    let color: Color
}
