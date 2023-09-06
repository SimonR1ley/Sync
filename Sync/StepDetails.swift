import SwiftUI
import Charts

struct StepDetails: View {
    @ObservedObject var manager: HealthKitManager = HealthKitManager()
    @State private var isViewActive = false
    @State private var stepData: [DaysOfTheWeek] = []
    @State private var filteredStepData: [DaysOfTheWeek] = []
    @State private var selectedDay: String = ""
    
    // Create a @State property to hold the Firebase step data
    @State private var firebaseStepData: [DaysOfTheWeek] = []

    // Initialize filteredStepData with the data for "Monday"
    init() {
        _filteredStepData = State(initialValue: stepData.filter { $0.day == "Monday" })
    }

    // Computed property to filter step data for the selected day
    var selectedDayStepData: [DaysOfTheWeek] {
        return stepData.filter { $0.day == selectedDay }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("DashboardBackground")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Step Data")
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

                        

                        Text("Steps this Week")
                            .padding()
                            .foregroundColor(.white)

                        ZStack {
                            Color(uiColor: .systemGray6)
                                .cornerRadius(15)
                            HStack(spacing: 10) { // Add spacing between charts
                                ForEach(manager.weeklyStepData) { element in
                                    Chart {
                                        BarMark(
                                            x: .value("Days", element.day),
                                            y: .value("Steps", element.amount),
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
                                    ForEach(manager.weeklyStepData.map { $0.day }, id: \.self) { day in
                                        Text(day)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
//                                .padding()
                                
                                if let selectedData = manager.weeklyStepData.first(where: { $0.day == selectedDay }) {
                                    VStack(alignment: .leading){
                                        Text("Steps on \(selectedData.day): \(selectedData.amount)")
                                            .padding()
                                            .foregroundColor(.white)
                                    }
                                   
                                } else {
                                    Text("No data available for selected day.")
                                        .padding()
                                        .foregroundColor(.white)
                                }
                        }.padding()
                        
                        

                        Text("My Saved Steps")
                            .padding()
                            .foregroundColor(.white)

                        ZStack {
                            Color(uiColor: .systemGray6)
                                .cornerRadius(15)
                          
                        }
                        .padding(.horizontal)
                        
                        
                        ForEach(firebaseStepData, id: \.day) { dayData in
                                         VStack {
                                             Text("Day: \(dayData.day)")
                                             Text("Steps: \(dayData.amount)")
                                         }
                                         .padding()
                                         .foregroundColor(.white)
                                     }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .navigationBarHidden(true)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                manager.fetchWeeklySteps()

                manager.fetchStepDataFromFirebase { stepData in
                    self.stepData = stepData
                    print("Fetched step data from Firebase: \(stepData)")
                }
            }
        }
    }
}

struct StepDetails_Previews: PreviewProvider {
    static var previews: some View {
        StepDetails()
    }
}
