//
//  ContentView.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color("DashboardBackground")
                .ignoresSafeArea()
       
            
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                
              
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
