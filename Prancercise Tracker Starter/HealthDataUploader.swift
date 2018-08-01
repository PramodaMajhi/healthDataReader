//
//  HealthDataUploader.swift
//  Health Data Reader-Writer
//
//  Created by Patrick Holmes on 7/31/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation

import UIKit
import HealthKit

struct HealthData : Encodable {
    let birthday : String?
    let biologicalSex: String?
    let bloodType : String?
    let fitzpatrickSkinType : String?
    let wheelchairUse : String?
    var heightInMeters: String?
    var weightInKilograms: String?
    
    init(birthday : DateComponents?, biologicalSex: HKBiologicalSex?, bloodType : HKBloodType?, fitzpatrickSkinType : HKFitzpatrickSkinType?, wheelchairUse : HKWheelchairUse? ) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        self.birthday = formatter.string(from: birthday!.date!)
        
        self.biologicalSex = biologicalSex!.stringRepresentation
        self.bloodType = bloodType!.stringRepresentation
        self.fitzpatrickSkinType = fitzpatrickSkinType!.stringRepresentation
        self.wheelchairUse = wheelchairUse!.stringRepresentation
    }
}

class HealthDataUploader {
    
    var healthData : HealthData?
    
    public func getData() {
        do {
            guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
                print("Height Sample Type is no longer available in HealthKit")
                return
            }
            
            guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
                print("Body Mass Sample Type is no longer available in HealthKit")
                return
            }
            
            self.healthData = try self.getValues()
            
            let taskGroup = DispatchGroup()
            
            taskGroup.enter()
            ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
                defer {
                    taskGroup.leave()
                }
                guard let sample = sample else {
                    return
                }
                let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                self.healthData!.heightInMeters = String(format:"%.2f", heightInMeters)
            }
            
            taskGroup.enter()
            ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
                defer {
                    taskGroup.leave()
                }
                guard let sample = sample else {
                    return
                }
                let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                self.healthData!.weightInKilograms = String(format:"%.2f", weightInKilograms)
            }
            
            taskGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
                var urlComponents = URLComponents()
                urlComponents.scheme = "http"
                urlComponents.host = "127.0.0.1" // 192.168.1.2"
                urlComponents.port = 3000
                urlComponents.path = "/healthData"
                guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
                
                // Specify this request as being a POST method
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                // Make sure that we include headers specifying that our request's HTTP body
                // will be JSON encoded
                var headers = request.allHTTPHeaderFields ?? [:]
                headers["Content-Type"] = "application/json"
                request.allHTTPHeaderFields = headers
                
                // Now let's encode out Post struct into JSON data...
                let encoder = JSONEncoder()
                do {
                    let jsonData = try encoder.encode(self.healthData)
                    // ... and set our request's HTTP body
                    request.httpBody = jsonData
                    print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
                } catch {
                    //completion?(error)
                }
                
                // Create and run a URLSession data task with our JSON encoded POST request
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: request) { (responseData, response, responseError) in
                    guard responseError == nil else {
                        //completion?(responseError!)
                        return
                    }
                    
                    // APIs usually respond with the data you just sent in your POST request
                    if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                        print("response: ", utf8Representation)
                    } else {
                        print("no readable data received in response")
                    }
                }
                task.resume()
            }))
            
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func getValues() throws -> HealthData {
        let healthKitStore = HKHealthStore()
        
        do {
            let birthday = try healthKitStore.dateOfBirthComponents()
            
            let biologicalSex = try healthKitStore.biologicalSex()
            let uwBiologicalSex = biologicalSex.biologicalSex
            
            let bloodType =  try healthKitStore.bloodType()
            let uwBloodType = bloodType.bloodType
            
            let fitzpatrickSkinType = try healthKitStore.fitzpatrickSkinType()
            let uwFitzpatrickSkinType = fitzpatrickSkinType.skinType
            
            let wheelchairUse = try healthKitStore.wheelchairUse()
            let uwWheelchairUse = wheelchairUse.wheelchairUse
            
            let result = HealthData(birthday: birthday, biologicalSex: uwBiologicalSex, bloodType: uwBloodType, fitzpatrickSkinType: uwFitzpatrickSkinType, wheelchairUse: uwWheelchairUse)
            return result
        }
    }
    

}

