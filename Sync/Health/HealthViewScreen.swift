//
//  HealthViewScreen.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/15.
//

import SwiftUI
import Charts
import FirebaseAuth 


struct DaysOfTheWeek: Identifiable {
     let day: String
     let amount: Double
     var id: String { day }
}






struct HealthViewScreen: View {
    
    @ObservedObject var manager: HealthKitManager
    
    @State private var isViewActive = false
    @State private var isViewCalorieActive = false
    @State private var showConfirmationAlert = false
    let userEmail = Auth.auth().currentUser
    
    init(manager: HealthKitManager) {
        self.manager = manager
        
        if let user = Auth.auth().currentUser {
            if let userEmail = user.email {
                manager.fetchDataFromFirestore(userEmail: userEmail)
            } else {
                print("User's email is nil")
            }
        } else {
            print("No user is logged in")
        }
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
                                                    showConfirmationAlert = true
                                                }
                                                .padding()
                                                .foregroundColor(.blue)
                                                .cornerRadius(10)
                                                .padding()
                                                .alert(isPresented: $showConfirmationAlert) {
                                                    Alert(
                                                        title: Text("Confirm Save"),
                                                        message: Text("Are you sure you want to save today's data?"),
                                                        primaryButton: .default(Text("Save")) {
                                                            manager.saveDataToFirestore()
                                                        },
                                                        secondaryButton: .cancel()
                                                    )
                                                }
                                            }
                        
                      
                        
                        Text("Today's Activity")
                            .padding()
                            .foregroundColor(.black)
                        
                        VStack() {
                            ForEach(manager.activities) { activity in
                                ActivityCard(activity: Activity(title: activity.title, amount: activity.amount, image: activity.image, color: activity.color))
                               
                            }
                        }
                        
              
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
        let manager = HealthKitManager() 
        return HealthViewScreen(manager: manager)
    }
}

