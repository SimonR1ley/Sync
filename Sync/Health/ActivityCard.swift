//
//  ActivityCard.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/16.
//

import SwiftUI


struct ActivityCard: View {
    @State var activity: Activity
    var body: some View {
        ZStack{
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            
            VStack(spacing: 16){
                
                HStack(alignment: .top){
                    VStack(alignment: .leading, spacing: 5){
                        Text(activity.title)
                            .font(.system(size: 16))
                        Text(activity.amount)
                            .font(.system(size: 24))
                        
                    }
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(activity.color)
                }
                .padding()
               
            }
            .padding()
            .cornerRadius(15)
        }
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(title: "Daily Steps", amount: "6,545", image: "figure.walk", color: .green))
        
        
    }
}
