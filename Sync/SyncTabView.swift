//
//  SyncTabView.swift
//  Sync
//
//  Created by Simon Riley on 2023/09/26.
//

import SwiftUI

struct SyncTabView: View {
    @State var selectedTab = "Home"
    var body: some View {
        TabView(selection: $selectedTab) {
            HealthViewScreen()
                .tag ("Home" )
                .tabItem {
                    Image (systemName: "house")
                }
            
            Details()
                .tag ("Details" )
                .tabItem {
                    Image (systemName: "person")
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
