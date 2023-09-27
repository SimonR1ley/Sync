import SwiftUI
import Charts

struct Details: View {
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
                        Text("Details")
                            .font(.system(size: 23, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)

      
                        Text("Steps this Week")
                            .padding()
                            .foregroundColor(.black)

                        ZStack {
                            Color(uiColor: .systemGray6)
                                .cornerRadius(15)
                            HStack(spacing: 10) { // Add spacing between charts
                           
                                    Chart(manager.weeklyStepData) {
                                        element in
                                        LineMark(
                                            x: .value("Days", element.day),
                                            y: .value("Steps", element.amount)
                                        )
                                     
                                    }
                                    .foregroundStyle(.orange)
                                
                            } .padding()
                           
                        } .padding()
                            .frame(height: 200)
                        
                        
                        ZStack {
                            Color(uiColor: .systemGray6)
                                .cornerRadius(15)
                            HStack(spacing: 10) { // Add spacing between charts
                                
                                    Chart(manager.weeklyStepData) {
                                        element in
                                        BarMark(
                                            x: .value("Days", element.day),
                                            y: .value("Steps", element.amount)
                                        )
                                     
                                    }
                                    .foregroundColor(Color(red: 216/255, green: 67/255, blue: 57/255))
                                    
                                    
                            
                                  
                                    
                                   
                            } .padding()
                           
                        } .padding()
                            .frame(height: 200)
                        
                        
                        VStack {
//                                Color(uiColor: .systemGray6)
//                                    .cornerRadius(15)
//                                    .padding()
                            
                      
                                
                                Picker("Select a Day", selection: $selectedDay) {
                                    ForEach(manager.weeklyStepData.map { $0.day }, id: \.self) { day in
                                        Text(day)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color(.systemGray6))
                                .cornerRadius(5)
//                                .padding()
                                
                                if let selectedData = manager.weeklyStepData.first(where: { $0.day == selectedDay }) {
                                    
                                    HStack() {
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("Steps on \(selectedData.day): \(selectedData.amount)")
                                                .padding()
                                                .foregroundColor(.white)
                                        }
                                        .background(Color(red: 216/255, green: 67/255, blue: 57/255))
                                        .cornerRadius(10)
                                        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 4)
                                        Spacer()
                                    }.padding()
                                    
                                 

                                   
                                } else {
                                  
                                    
                                    HStack() {
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("No data available for selected day.")
                                                .padding()
                                                .foregroundColor(.white)
                                        }
                                        .background(Color(red: 216/255, green: 67/255, blue: 57/255))
                                        .cornerRadius(10)
                                        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 4)
                                        Spacer()
                                    }.padding()
                                }
                        }.padding()
                        
                        

                        Text("My Saved Steps")
                            .padding()
                            .foregroundColor(.white)

                    
                        
                        
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

struct Details_Previews: PreviewProvider {
    static var previews: some View {
        Details()
    }
}
