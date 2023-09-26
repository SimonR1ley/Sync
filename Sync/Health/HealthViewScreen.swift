//
//  HealthViewScreen.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/15.
//

import SwiftUI
import Charts


struct DaysOfTheWeek: Identifiable {
     let day: String
     let amount: Double
     var id: String { day }
}






struct HealthViewScreen: View {
    
    @ObservedObject var manager: HealthKitManager = HealthKitManager()
    
    @State private var isViewActive = false
    
    @State private var isViewCalorieActive = false
    
    init() {
         manager.fetchWeeklySteps()
        manager.fetchWeeklyCalories()
     }
    
    var body: some View {
        
        NavigationView{
            
            ZStack{
                Color("DashboardBackground")
                    .ignoresSafeArea()
                ScrollView{
                    
                    
                    VStack(alignment: .leading){
                        
                        HStack{
                            
                            Text("Dashboard")
                                .font(.system(size: 23, weight: .bold, design: .default))
                                .foregroundColor(.black)
                                .padding()
                            
                            Spacer()
                            
                            Button("Save Today's data") {
                                          manager.saveDataToFirestore()
                                      }
                                      .padding()
                                      .foregroundColor(.blue)
//                                      .background(Color.white)
                                      .cornerRadius(10)
                                      .padding()
                            
                        }
                        
                      
                        
                        Text("Today's Activity")
                            .padding()
                            .foregroundColor(.black)
                        
                        VStack() {
                            ForEach(manager.activities) { activity in
                                ActivityCard(activity: activity, manager: manager) // Pass the manager instance
                                    .onTapGesture {
                                        if activity.title == "Steps" {
                                            // Navigate to StepDetails
                                        }
                                    }
                                    .background(
                                        NavigationLink("", destination: StepDetails())
                                            .opacity(0) // Make the link invisible
                                    )
                            }
                        }
//                        .padding()



                        
//                        HStack{
//                            Text("Steps this Week")
//                                .padding()
//                                .foregroundColor(.white)
//                            
//                            Spacer()
//                            
//                            Button("View more") {
//                                isViewActive = true
//                            }
//                            .background(NavigationLink("", destination: StepDetails(), isActive: $isViewActive))
//                            .padding()
//                            .foregroundColor(.blue)
//                        }
                        
                        
//                        ZStack {
//                            Color(uiColor: .systemGray6)
//                                .cornerRadius(15)
//                            HStack(spacing: 10) { // Add spacing between charts
//                                ForEach(manager.weeklyStepData) { element in
//                                    Chart {
//                                        BarMark(
//                                            x: .value("Days", element.day),
//                                            y: .value("Steps", element.amount),
//                                            width: 5
//                                        )
//                                        .foregroundStyle(by: .value("Days", element.day))
//                                    }
//                                    .chartForegroundStyleScale([element.day: Color(.white)])
//                                    .foregroundColor(.green)
//                                }
//                            } .padding()
//                           
//                        } .padding()
//                            .frame(height: 200)
                        
//                        HStack{
//                            Text("Calories this Week")
//                                .padding()
//                                .foregroundColor(.white)
//                            
//                            Spacer()
//                            
//                            Button("View more") {
//                                isViewCalorieActive = true
//                            }
//                            .background(NavigationLink("", destination: CalorieDetails(), isActive: $isViewCalorieActive))
//                            .padding()
//                            .foregroundColor(.blue)
//                        }
//                        
                        
//                        ZStack {
//                            Color(uiColor: .systemGray6)
//                                .cornerRadius(15)
//                            HStack(spacing: 20) { // Add spacing between charts
//                                ForEach(manager.weeklyCaloriesData) { element in
//                                    Chart {
//                                        BarMark(
//                                            x: .value("Days", element.day),
//                                            y: .value("Calories", element.amount),
//                                            width: 5
//                                        )
//                                        .foregroundStyle(by: .value("Days", element.day))
//                                        
//                                    }
//                                    .chartForegroundStyleScale([element.day: Color(.white)])
//                          
//                                }
//                            } .padding()
//                            
//                        }.padding(.horizontal)
                        
                        
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .navigationBarHidden(true)
                }
            }
        }.navigationBarHidden(true)
    }
}

struct HealthViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        HealthViewScreen()
    }
}
