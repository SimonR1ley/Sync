//
//  OnBoardingTwo.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/10.
//

import SwiftUI

struct OnBoardingTwo: View {
    
    @State private var isViewActive = false
    let manager = HealthKitManager()
    var body: some View {
        NavigationView{
            VStack{
                
                
                
                Text("What is Sync?")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.black)
                
                
                //            Space
                Text("")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(.black)
                
                Text("Sync is a running tracker. Sync pulls your information from your health app and displays your data in a dashboard format. Note this app requires the use of an apple watch.")
                    .font(.system(size: 20, design: .default))
                    .foregroundColor(.black)
                    .frame(width:340, height: 200)
                
                Button("Continue") {
                    isViewActive = true
                }
                .foregroundColor(.black)
                .frame(width:300, height: 50)
                .background(NavigationLink("", destination: SyncTabView(), isActive: $isViewActive))
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("onBoardingTwo"))
            .edgesIgnoringSafeArea(.all)
        } .navigationBarHidden(true) 
    }
}

struct OnBoardingTwo_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingTwo()
    }
}
