
//  HealthKitManager.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/15.
//

import Foundation
import HealthKit
import SwiftUI
import Firebase
import FirebaseFirestore

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    let db = Firestore.firestore()
    
    @Published var activities: [Activity] = []
    @Published var database: [Database] = []
    @Published var weeklyStepData: [DaysOfTheWeek] = []
    @Published var weeklyCaloriesData: [DaysOfTheWeek] = []
    
    @Published var heartRateValue: Int = 0
    
//    if let user = Auth.auth().currentUser {
//        let userEmail = user.email
//        // userEmail now contains the email of the currently logged-in user
//    }
    
    
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            
            let healthTypes: Set = [steps, calories, heartRate]
            
            Task {
                do {
                    try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                    
                    fetchDailySteps()
                    fetchDailyCalories()
                    fetchWeeklyCalories()
                    
                } catch {
                    print("Error retrieving HealthKit")
                }
            }
        }
    }
    

    func autorizeHealthKit() {
         
         // Used to define the identifiers that create quantity type objects.
           let healthKitTypes: Set = [
           HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        // Requests permission to save and read the specified data types.
           healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
       }
    
    
    func fetchDailySteps(){
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for:    Date()), end: Date())
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate){
            _, result, error in
            
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching today's steps: \(error?.localizedDescription ?? "")")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            print("Total Steps: \(stepCount)" )
            
            self.activities.append(Activity(title: "Today's Steps",  amount: "\(stepCount.rounded(.towardZero))", image: "figure.walk.circle", color:.green))
        }
        
        healthStore.execute(query)
        
        
    }

    
    func fetchDailyCalories(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for:    Date()), end: Date())
        
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate){
            _, result, error in
            
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching today's steps: \(error?.localizedDescription ?? "")")
                return
            }
            
            let caloriesTotal = quantity.doubleValue(for: .kilocalorie())
            print("Total Calories: \(caloriesTotal)" )
            
            self.activities.append(Activity(title: "Today's Calories",  amount: "\(caloriesTotal.rounded(.towardZero))", image: "flame.circle", color:.orange))
        }
        
        healthStore.execute(query)
        
    }
    
    func fetchWeeklySteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!)
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: endOfWeek)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            if let error = error {
                print("Error fetching weekly steps: \(error.localizedDescription)")
                return
            }
            
            var stepsByDay: [String: Double] = [:]
            
            if let stepSamples = samples as? [HKQuantitySample] {
                for sample in stepSamples {
                    let day = calendar.component(.weekday, from: sample.startDate)
                    let currentStepCount = stepsByDay["\(day)"] ?? 0
                    stepsByDay["\(day)"] = currentStepCount + sample.quantity.doubleValue(for: .count())
                }
            }
            
            print("Steps by day: \(stepsByDay)")
            
            self.weeklyStepData = [
                DaysOfTheWeek(day: "Mon", amount: stepsByDay["2"] ?? 0),
                DaysOfTheWeek(day: "Tue", amount: stepsByDay["3"] ?? 0),
                DaysOfTheWeek(day: "Wed", amount: stepsByDay["4"] ?? 0),
                DaysOfTheWeek(day: "Thu", amount: stepsByDay["5"] ?? 0),
                DaysOfTheWeek(day: "Fri", amount: stepsByDay["6"] ?? 0),
                DaysOfTheWeek(day: "Sat", amount: stepsByDay["7"] ?? 0),
                DaysOfTheWeek(day: "Sun", amount: stepsByDay["1"] ?? 0)
            ]
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeeklyCalories() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!)
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: endOfWeek)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        
        let query = HKSampleQuery(sampleType: caloriesType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            if let error = error {
                print("Error fetching weekly calories: \(error.localizedDescription)")
                return
            }
            
            var caloriesByDay: [String: Double] = [:]
            
            if let calorieSamples = samples as? [HKQuantitySample] {
                for sample in calorieSamples {
                    let day = calendar.component(.weekday, from: sample.startDate)
                    let currentCalorieCount = caloriesByDay["\(day)"] ?? 0
                    caloriesByDay["\(day)"] = currentCalorieCount + sample.quantity.doubleValue(for: .kilocalorie())
                }
            }
            
            print("Calories by day: \(caloriesByDay)")
            
            self.weeklyCaloriesData = [
                DaysOfTheWeek(day: "Mon", amount: caloriesByDay["2"] ?? 0),
                DaysOfTheWeek(day: "Tue", amount: caloriesByDay["3"] ?? 0),
                DaysOfTheWeek(day: "Wed", amount: caloriesByDay["4"] ?? 0),
                DaysOfTheWeek(day: "Thu", amount: caloriesByDay["5"] ?? 0),
                DaysOfTheWeek(day: "Fri", amount: caloriesByDay["6"] ?? 0),
                DaysOfTheWeek(day: "Sat", amount: caloriesByDay["7"] ?? 0),
                DaysOfTheWeek(day: "Sun", amount: caloriesByDay["1"] ?? 0)
            ]
        }

        healthStore.execute(query)
    }
    
    
    
    
//    FIREBASE
    
    
    func getDailySteps(completion: @escaping (Double) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            if let sum = result?.sumQuantity() {
                DispatchQueue.main.async {
                    // Handle or store the daily step count
                    let stepCount = sum.doubleValue(for: HKUnit.count())
                    print("Daily Steps: \(stepCount)")
                    completion(stepCount) // Call the completion handler with the result
                }
            }
        }
        healthStore.execute(query)
    }

    
    func getDailyCalories(completion: @escaping (Double) -> Void) {
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate) { _, result, _ in
            if let sum = result?.sumQuantity() {
                // Handle or store the daily calorie data
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                DispatchQueue.main.async {
                    completion(calories) // Call the completion handler with the result
                }
            }
        }
        healthStore.execute(query)
    }
    
        func saveDataToFirestore() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todayDateString = dateFormatter.string(from: Date())

            var steps: Double = 0.0
            var calories: Double = 0.0

            let dispatchGroup = DispatchGroup()

            // Perform the HealthKit queries in a Dispatch Group to wait for both values to be available
            dispatchGroup.enter()
            getDailySteps { [self] stepCount in // Capture self explicitly
                steps = stepCount
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            getDailyCalories { [self] calorieCount in // Capture self explicitly
                calories = calorieCount
                dispatchGroup.leave()
            }

            // Wait for both queries to complete
            dispatchGroup.notify(queue: .main) {
                // Obtain the currently logged-in user's email
                if let user = Auth.auth().currentUser, let userEmail = user.email {
                    let dailyData: [String: Any] = [
                        "date": todayDateString,
                        "steps": steps,
                        "calories": calories,
                        "userEmail": userEmail // Include user's email in the data
                    ]

                    self.db.collection("healthdata").addDocument(data: dailyData) { error in
                        if let error = error {
                            print("Error saving data to Firestore: \(error)")
                        } else {
                            print("Data saved to Firestore")
                        }
                    }
                } else {
                    print("User is not authenticated.")
                }
            }
        }



    
   
    
    
    func fetchDataFromFirestore(userEmail: String) {
        guard database.isEmpty else {
            return // Data has already been fetched
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date())

        // Reference to the Firestore collection
        let collectionReference = self.db.collection("healthdata")

        // Query Firestore for documents with today's date and matching userEmail
        collectionReference
            .whereField("date", isEqualTo: todayDateString)
            .whereField("userEmail", isEqualTo: userEmail) // Add this line to filter by userEmail
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error retrieving data from Firestore: \(error)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }

                for document in documents {
                    let data = document.data()
                    if let date = data["date"] as? String,
                       let steps = data["steps"] as? Double,
                       let calories = data["calories"] as? Double {

                        // Append data to your self.database array
                        self.database.append(Database(date: date, calories: "\(calories.rounded(.towardZero))", steps: "\(steps.rounded(.towardZero))", image: "star.circle", color: Color(red: 216/255, green: 67/255, blue: 57/255)))
                    }
                }

                // Now your self.database array is populated with data from Firestore
                print("Data retrieved from Firestore")
            }
    }




}
