//
//  HealthViewScreen.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/15.
//

import SwiftUI
import Charts
import FirebaseAuth // Import FirebaseAuth to access the user's email

struct SavedData: View {
    
    @ObservedObject var manager: HealthKitManager
    @State private var isViewActive = false
    @State private var isViewCalorieActive = false
    @State private var dataFetched = false // Track whether data has been fetched
    
    init(manager: HealthKitManager) {
        self.manager = manager
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DashboardBackground")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("My Saved Days")
                                .font(.system(size: 23, weight: .bold, design: .default))
                                .foregroundColor(.black)
                                .padding()
                            Spacer()
                        }
//                        Text("My Saved Days")
//                            .padding()
//                            .foregroundColor(.black)
                        VStack() {
                            if !dataFetched {
                                ProgressView("Fetching data...")
                                    .onAppear {
                                        if let user = Auth.auth().currentUser, let userEmail = user.email {
                                            manager.fetchDataFromFirestore(userEmail: userEmail)
                                            dataFetched = true
                                        } else {
                                            // Handle the case where the user is not logged in
                                        }
                                    }
                            } else {
                                ForEach(manager.database) { activity in
                                    FirestoreCard(database: activity)
                                }
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
