
//
//  ActivityCard.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/16.
//

import SwiftUI


struct FirestoreCard: View {
    var database: Database
    
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(database.date)
                        .font(.headline)
                    
                    Text("Steps")
                    Text(database.steps)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Calories")
                    Text(database.calories)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: database.image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(database.color)
            }
            .padding()
            .foregroundColor(Color.black)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(database.color, lineWidth: 2)
            )
            .padding()
        }
        .background(Color.clear)
    }
}

struct FirestoreCard_Previews: PreviewProvider {
    static var previews: some View {
        FirestoreCard(database: Database(date: "01/01/99", calories: "6,545", steps: "6,545", image: "star.circle", color: .green))
        
        
    }
}
//Image(systemName: "star.circle")

