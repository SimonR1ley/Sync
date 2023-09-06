//
//  SplashScreen.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/02.
//

import SwiftUI

struct SplashScreen: View {
    
    @State private var isActive = false
    
    var body: some View {
        
        if isActive{
            Login()
        } else {
            VStack{
                
         HeartBeatView()
                
//                Text("Sync")
//                    .font(.system(size: 30, weight: .bold, design: .default))
//                    .foregroundColor(.black.opacity(0.80))
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.white))
            .edgesIgnoringSafeArea(.all)
            .onAppear{
                          DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                              self.isActive = true
                          }
                      }
            
        }
      
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
