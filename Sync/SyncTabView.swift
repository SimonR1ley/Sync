//
//  SyncTabView.swift
//  Sync
//
//  Created by Simon Riley on 2023/09/26.
//

import SwiftUI

struct SyncTabView: View {
    @State var selectedTab = "Home"
    let manager = HealthKitManager() // Create an instance of HealthKitManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HealthViewScreen(manager: manager) // Pass the manager to the HealthViewScreen
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                }
            
            Details()
                .tag("Details")
                .tabItem {
                    Image(systemName: "doc.text.below.ecg.fill")
                }
            
            
            SavedData(manager: manager)
                .tag("SavedData")
                .tabItem {
                    Image(systemName: "star.circle")
                }
        }
        .foregroundColor(.white)
    }
}

struct SyncTabView_Previews: PreviewProvider {
    static var previews: some View {
        SyncTabView()
    }
}
