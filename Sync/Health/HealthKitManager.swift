//
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
    @Published var weeklyStepData: [DaysOfTheWeek] = []
    @Published var weeklyCaloriesData: [DaysOfTheWeek] = []
    
    @Published var heartRateValue: Int = 0
    
    
    
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
                    startHeartRateQuery(quantityTypeIdentifier: .heartRate)
                    fetchDailyCalories()
                    fetchWeeklyCalories()
                    
                } catch {
                    print("Error retrieving HealthKit")
                }
            }
        }
    }
    
    // Implement this method to retrieve daily step count from HealthKit
    func getDailySteps() -> Double {
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
                    // You can update your UI or save the data to Firestore here
                }
            }
        }
        healthStore.execute(query)
        // You may return 0.0 or another default value here
        return 0.0
    }

    // Implement this method to retrieve daily calorie data from HealthKit
    func getDailyCalories() -> Double {
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            if let sum = result?.sumQuantity() {
                DispatchQueue.main.async {
                    // Handle or store the daily calorie data
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    print("Daily Calories: \(calories)")
                    // You can update your UI or save the data to Firestore here
                }
            }
        }
        healthStore.execute(query)
        // You may return 0.0 or another default value here
        return 0.0
    }
    
    func saveDataToFirestore() {
         // Implement this method to save data to Firestore
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd"
         let todayDateString = dateFormatter.string(from: Date())

         let dailyData: [String: Any] = [
             "date": todayDateString,
             "steps": getDailySteps(),
             "calories": getDailyCalories()
         ]

         db.collection("healthdata").addDocument(data: dailyData) { error in
             if let error = error {
                 print("Error saving data to Firestore: \(error)")
             } else {
                 print("Data saved to Firestore")
             }
         }
     }

    // Call this method once per day to save daily data to Firestore
    func saveDailyDataIfNeeded() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let currentMonth = dateFormatter.string(from: Date())

        // Implement a check to determine if it's a new month
        // If it's a new month, reset or archive your data as needed
        // For example, you can compare the currentMonth with the stored month in Firestore
        // If they don't match, it's a new month, and you can reset or archive data.
        
        // Once you've reset or archived the data, call saveDailyDataToFirestore()
        // to start collecting data for the new month.
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
        let currentDate = Date()
        
        // Calculate the start date of the current week
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        
        // Calculate the end date of the current week
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
        let currentDate = Date()
        
        // Calculate the start date of the current week
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        
        // Calculate the end date of the current week
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


  
    
 
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // variable initialization
        var lastHeartRate = 0.0

        // cycle and value assignment
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }

            // Update the heart rate value property
            self.heartRateValue = Int(lastHeartRate)
        }
    }

    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            self.process(samples, type: quantityTypeIdentifier)
            
            // Logging heart rate values
            let heartRateValues = samples.map { sample in
                return sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
            print("Heart Rate Values: \(heartRateValues)")
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        healthStore.execute(query)
    }
    
    
    
    func fetchStepDataFromFirebase(completion: @escaping ([DaysOfTheWeek]) -> Void) {
        // Replace 'healthdata' with the name of your Firestore collection
        db.collection("healthdata").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching health data from Firestore: \(error)")
                completion([])
                return
            }
            
            var stepData: [DaysOfTheWeek] = []
            
            for document in querySnapshot!.documents {
                if let data = document.data() as? [String: Any],
                   let timestamp = data["timestamp"] as? Timestamp,
                   let steps = data["steps"] as? Double {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd" // Use the desired date format
                    
                    let day = dateFormatter.string(from: timestamp.dateValue()) // Extract day from the timestamp
                    
                    stepData.append(DaysOfTheWeek(day: day, amount: steps))
                }
            }
            
            completion(stepData)
        }
    }

    
    func fetchDailyData() {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        // Fetch step count
        let stepQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate) { _, result, error in
            if let sum = result?.sumQuantity() {
                let stepCount = sum.doubleValue(for: HKUnit.count())
                print("Daily Steps: \(stepCount)")
                self.activities.append(Activity(title: "Today's Steps", amount: "\(stepCount.rounded(.towardZero))", image: "figure.walk.circle", color: .green))
            }
        }

        // Fetch calorie count
        let calorieQuery = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate) { _, result, error in
            if let sum = result?.sumQuantity() {
                let caloriesTotal = sum.doubleValue(for: HKUnit.kilocalorie())
                print("Daily Calories: \(caloriesTotal)")
                self.activities.append(Activity(title: "Today's Calories", amount: "\(caloriesTotal.rounded(.towardZero))", image: "flame.circle", color: .orange))
            }
        }

        // Fetch heart rate
        let heartRateQuery = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate) { _, result, error in
            if let sum = result?.averageQuantity() {
                let heartRate = sum.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                print("Heart Rate: \(heartRate) BPM")
                self.heartRateValue = Int(heartRate)
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(calorieQuery)
        healthStore.execute(heartRateQuery)
    }

    
    
    func fetchCalorieDataFromFirebase(completion: @escaping ([DaysOfTheWeek]) -> Void) {
        // Replace 'healthdata' with the name of your Firestore collection
        db.collection("healthdata").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching health data from Firestore: \(error)")
                completion([])
                return
            }
            
            var calorieData: [DaysOfTheWeek] = []
            
            for document in querySnapshot!.documents {
                if let data = document.data() as? [String: Any],
                   let timestamp = data["timestamp"] as? Timestamp,
                   let calories = data["calories"] as? Double {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd" // Use the desired date format
                    
                    let day = dateFormatter.string(from: timestamp.dateValue()) // Extract day from the timestamp
                    
                    calorieData.append(DaysOfTheWeek(day: day, amount: calories))
                }
            }
            
            completion(calorieData)
        }
    }



}
