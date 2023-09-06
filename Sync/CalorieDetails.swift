//
//  CalorieDetails.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/23.
//

import SwiftUI
import Charts

struct CalorieDetails: View {
    
    @ObservedObject var manager: HealthKitManager = HealthKitManager()
    @State private var isViewActive = false
    @State private var calorieData: [DaysOfTheWeek] = []
    @State private var filteredCalorieData: [DaysOfTheWeek] = []
    @State private var selectedDay: String = ""

    // Initialize filteredStepData with the data for "Monday"
    init() {
        _filteredCalorieData = State(initialValue: calorieData.filter { $0.day == "Monday" })
    }

    // Computed property to filter step data for the selected day
    var selectedDayStepData: [DaysOfTheWeek] {
        return calorieData.filter { $0.day == selectedDay }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("DashboardBackground")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Calorie Data")
                            .font(.system(size: 23, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)

                        VStack(alignment: .leading) {
                            Text("Today's Activity")
                                .padding()
                                .foregroundColor(.white)

                            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                                ForEach(manager.activities) { activity in
                                    ActivityCard(activity: Activity(title: activity.title, amount: activity.amount, image: activity.image, color: activity.color))
                                }
                            }
                            .padding(.horizontal)
                        }

                        

                        Text("Calories this Week")
                            .padding()
                            .foregroundColor(.white)

                        ZStack {
                            Color(uiColor: .systemGray6)
                                .cornerRadius(15)
                            HStack(spacing: 20) { // Add spacing between charts
                                ForEach(manager.weeklyCaloriesData) { element in
                                    Chart {
                                        BarMark(
                                            x: .value("Days", element.day),
                                            y: .value("Calories", element.amount),
                                            width: 5
                                        )
                                        .foregroundStyle(by: .value("Days", element.day))
                                    }
                                    .chartForegroundStyleScale([element.day: Color(.white)])
                                }
                            } .padding()
                           
                        } .padding()
                            .frame(height: 200)
                        
                        
                        
                        VStack {
                                Color(uiColor: .systemGray6)
                                    .cornerRadius(15)
                                    .padding()
                                
                                Picker("Select a Day", selection: $selectedDay) {
                                    ForEach(manager.weeklyCaloriesData.map { $0.day }, id: \.self) { day in
                                        Text(day)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
//                                .padding()
                                
                                if let selectedData = manager.weeklyCaloriesData.first(where: { $0.day == selectedDay }) {
                                    Text("Calories on \(selectedData.day): \(selectedData.amount)")
                                        .padding()
                                } else {
                                    Text("No data available for selected day.")
                                        .padding()
                                }
                        }.padding()
                        
                        

                        Text("My Saved Calories")
                            .padding()
                            .foregroundColor(.white)

                        ZStack {
                            Color(uiColor: .systemGray6)
                                .cornerRadius(15)
                          
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .navigationBarHidden(true)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                manager.fetchWeeklyCalories()

                manager.fetchCalorieDataFromFirebase { calorieData in
                    self.calorieData = calorieData
                }
            }
        }
    }
}

struct CalorieDetails_Previews: PreviewProvider {
    static var previews: some View {
        CalorieDetails()
    }
}
