//
//  OnBoardingOne.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/10.
//

import SwiftUI

struct OnBoardingOne: View {
    
    @State private var isViewActive = false
    var body: some View {
        NavigationView{
            VStack{
                
                Image("logo")
                    .resizable()
                    .frame(width: 230, height: 230)
                
                
                
                Text("Welcome to Sync")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white.opacity(0.80))
                
                Button("Continue") {
                    isViewActive = true
                }
                .foregroundColor(.white)
                .frame(width:300, height: 50)
                .background(NavigationLink("", destination: OnBoardingTwo(), isActive: $isViewActive))
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 216/255, green: 67/255, blue: 57/255))
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}

struct OnBoardingOne_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingOne()
    }
}
