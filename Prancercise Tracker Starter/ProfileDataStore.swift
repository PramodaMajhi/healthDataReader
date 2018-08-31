/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import HealthKit

class ProfileDataStore {
        
    class func getAgeSexAndBloodType() -> (age: Int?, biologicalSex: HKBiologicalSex?, bloodType: HKBloodType?) {
        
        let healthKitStore = HKHealthStore()
        
        let birthdayComponents =  try? healthKitStore.dateOfBirthComponents()
        let biologicalSex =       try? healthKitStore.biologicalSex()
        let bloodType =           try? healthKitStore.bloodType()
        
        var age : Int? = nil
        if birthdayComponents != nil {
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year], from: today)
            let thisYear = todayDateComponents.year!
            age = thisYear - birthdayComponents!.year!
        }
        
        let unwrappedBiologicalSex = biologicalSex?.biologicalSex
        let unwrappedBloodType = bloodType?.bloodType
        
        return (age, unwrappedBiologicalSex, unwrappedBloodType)
    }
    
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(mostRecentSample, nil)
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    class func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
        
        //1.  Make sure the body mass type exists
        guard let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
            fatalError("Body Mass Index Type is no longer available in HealthKit")
        }
        
        //2.  Use the Count HKUnit to create a body mass quantity
        let bodyMassQuantity = HKQuantity(unit: HKUnit.count(),
                                          doubleValue: bodyMassIndex)
        
        let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType,
                                                   quantity: bodyMassQuantity,
                                                   start: date,
                                                   end: date)
        
        //3.  Save the same to HealthKit
        HKHealthStore().save(bodyMassIndexSample) { (success, error) in
            
            if let error = error {
                print("Error Saving BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully saved BMI Sample")
            }
        }
    }
    
    class func testSourceQuery(){
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        var datasources: [String] = []
        let query = HKSourceQuery.init(sampleType: bodyMassType,
                                       samplePredicate: nil) { (query, sources, error) in
                                        for source in sources! {
                                            print("Source :  \(source.name)")
                                            datasources.append(source.name)
                                        }
                                    }
        
            HKHealthStore().execute(query)
        }
    
    class func getSourceQuery(for sampleType: HKSampleType, completion: @escaping ([String]) -> ()) {
        var datasources: [String] = []
        let query = HKSourceQuery.init(sampleType: sampleType,
                                       samplePredicate: nil) { (query, sources, error) in
                                        for source in sources! {
                                            print("Source :  \(source.name)")
                                            datasources.append(source.name)
                                        }
                                        completion(datasources)
                    }
        
        HKHealthStore().execute(query)
        
    }
    
    class func getFitness() {
        let stepsCount = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount!,
                                             predicate: nil,
                                             limit: 10000,
                                             sortDescriptors: nil)  {
                                                (query, results, error) in
                                                if let results = results as? [HKQuantitySample] {
                                                    for result in results {
                                                        print("device: \(result.device) steps:\(result)" )
                                                    }
                                                }
        }
        
        HKHealthStore().execute(stepsSampleQuery)
    }
    
    class func retrieveSleepAnalysis(completion: @escaping (HKCategorySample?, Error?) -> Swift.Void) {
        
     
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
           // let datePredicate = HKQuery.predicateForSamples(withStart: nil, end: nil, options: .strictEndDate)
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                    //2. Always dispatch to the main thread when complete.
                DispatchQueue.main.async {
                    
                    guard let samples = tmpResult,
                        let mostRecentSample = samples.first as? HKCategorySample else {
                            
                            completion(nil, error)
                            return
                    }
                    completion(mostRecentSample, nil)
                  }
            }
            
            // finally, we execute our query
            HKHealthStore().execute(query)
        }
    }

    
    class func getTodaysSteps(for sampleType: HKQuantityType, completion: @escaping (Double?, HKStatistics?, Error?) -> Void) {
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .cumulativeSum) {query, result, error in
            
            DispatchQueue.main.async {
                guard let result = result,
                    let sum = result.sumQuantity() else {
                        completion(0.0, nil, error)
                    return
                }
                completion(sum.doubleValue(for: HKUnit.count()), result,  nil)
            }
        }
        
        HKHealthStore().execute(query)
    }
 
    // Pramod added to read heart rate
    class func createHeartRateStreamingQuery(_startDate: Date)  -> HKQuery?{
        
        var anchor: HKQueryAnchor?
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: _startDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type:
        heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) {
            (query, sampleObjects, deletedObjects, newAnchor, error) in
            
            guard let newAnchor = newAnchor,
                  let sampleObjects = sampleObjects else  {
                    return
            }
           anchor = newAnchor
        }
        
        heartRateQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else  {
                    return
            }
            anchor = newAnchor
        }
        return heartRateQuery
    }
    
}

