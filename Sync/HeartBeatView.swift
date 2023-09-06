//
//  HeartBeatView.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/23.
//

import SwiftUI

struct HeartBeatView : View {
    @State var trimValue1 : CGFloat = 0
    @State var trimValue2 : CGFloat = 0

    //MARK:- Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            
            HeartShapeHeartBeat()
                .stroke(lineWidth: 9)
                .foregroundColor(Color.black.opacity(0.1))
            
            HeartShapeHeartBeat()
                .trim(from: trimValue1, to: trimValue2)
                .stroke(lineWidth: 9)
                .foregroundColor(.red)
            
        }
        //MARK:- ZStack modifiers
        .frame(width: 350, height: 120)
        .animation(.spring())
        .onReceive(timer, perform: { _ in
            if trimValue2 == 0 {
                trimValue2 = 1
            }
            else if trimValue1 == 0 {
                trimValue1 = 1
            } else {
                trimValue2 = 0
                trimValue1 = 0
            }
        })
    }
}

struct HeartBeatView_Previews: PreviewProvider {
    static var previews: some View {
        HeartBeatView()
    }
}
