
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
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(activity.title)
                        .font(.headline)
                    Text(activity.amount)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: activity.image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(activity.color)
            }
            .padding()
            .foregroundColor(Color.black)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(activity.color, lineWidth: 2)
            )
            .padding()
        }
        .background(Color.clear) 
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(title: "Daily Steps", amount: "6,545", image: "figure.walk", color: .green))
        
        
    }
}




//
//  ActivityCard.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/16.
//
//
//import SwiftUI
//
//
//struct ActivityCard: View {
//    @State var activity: Activity
//    @ObservedObject var manager: HealthKitManager
//    
//    init(activity: Activity, manager: HealthKitManager) {
//        self._activity = State(initialValue: activity)
//        self.manager = manager
//    }
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            HStack {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(activity.title)
//                        .font(.headline)
//                    Text(activity.amount)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
////                    Text("Heart Rate: \(manager.heartRateValue) BPM") // Display heart rate
////                        .font(.subheadline)
//                }
//                Spacer()
//                Image(systemName: activity.image)
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(activity.color)
//            }
//            .padding()
//            .foregroundColor(Color.black)
//            .background(
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color(.white))
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(activity.color, lineWidth: 2)
//            )
//            .padding()
//        }
//        .background(Color.clear) // To avoid overlapping backgrounds
//    }
//}
//
//struct ActivityCard_Previews: PreviewProvider {
//    static var previews: some View {
//        let manager = HealthKitManager() // Create a HealthKitManager for previews
//        return  Activity(title: "Today's Steps", amount: "6,545", image: "figure.walk.circle", color: .green) // Create a mock Activity
//
//    }
//}


