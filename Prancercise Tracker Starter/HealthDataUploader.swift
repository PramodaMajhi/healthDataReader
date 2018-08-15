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

struct Attribute : Encodable {
    let attributeType: String?
    let attributeValue: String?
}

struct Measurement : Encodable {
    let uuid: UUID?
    let startDate: Date?
    let endDate: Date?
    let measurementType: String?
    let measurementValue: String?
    let unitOfMeasure: String?
}

struct HealthData : Encodable {
    let memberId: String?
    var attributes: [Attribute] = []
    var measurements: [Measurement] = []
    
    init(memberId: String) {
        self.memberId = memberId
    }
}
    
class HealthDataUploader {
    
    var healthData = HealthData(memberId: "XEA123456")
    
   
    public func getDataAndUpload() {
        do {
            guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
                print("Height Sample Type is no longer available in HealthKit")
                return
            }
            
            guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
                print("Body Mass Sample Type is no longer available in HealthKit")
                return
            }
            
            //let formatter = ISO8601DateFormatter()
            //self.healthData!.heightCaptureTimestamp = formatter.string(from: sample.endDate)
            
            let attributes = try self.getAttributes()
            self.healthData.attributes.append(contentsOf: attributes)
            
            let taskGroup = DispatchGroup()
            
            taskGroup.enter()
            ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
                defer {
                    taskGroup.leave()
                }
                if let sample = sample {
                    let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                    let measurement = Measurement(uuid: sample.uuid,
                                                  startDate: sample.startDate,
                                                  endDate: sample.endDate,
                                                  measurementType: "Height",
                                                  measurementValue: String(format:"%.2f", heightInMeters),
                                                  unitOfMeasure: "M")
                    self.healthData.measurements.append(measurement)
                }
            }
            
            taskGroup.enter()
            ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
                defer {
                    taskGroup.leave()
                }
                if let sample = sample  {
                    let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    let measurement = Measurement(uuid: sample.uuid,
                                                  startDate: sample.startDate,
                                                  endDate: sample.endDate,
                                                  measurementType: "Weight",
                                                  measurementValue: String(format:"%.2f", weightInKilograms),
                                                  unitOfMeasure: "Kg")
                    self.healthData.measurements.append(measurement)
                }
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
                encoder.dateEncodingStrategy = .iso8601
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
    
    public func getAttributes() throws -> [Attribute] {
        let healthKitStore = HKHealthStore()
        
        var attributes: [Attribute] = []
        
        do {
            if let birthday = try? healthKitStore.dateOfBirthComponents() {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate]
                let birthdayStr = formatter.string(from: birthday.date!)
                attributes.append(Attribute(attributeType: "DOB", attributeValue: birthdayStr))
            }
            
            if let biologicalSex = try? healthKitStore.biologicalSex() {
                let uwBiologicalSex = biologicalSex.biologicalSex
                attributes.append(Attribute(attributeType: "BiologicalSex", attributeValue: uwBiologicalSex.stringRepresentation))
            }
            
            if let bloodType =  try? healthKitStore.bloodType() {
                let uwBloodType = bloodType.bloodType
                attributes.append(Attribute(attributeType: "BloodType", attributeValue: uwBloodType.stringRepresentation))
            }
            
            if let fitzpatrickSkinType = try? healthKitStore.fitzpatrickSkinType() {
                let uwFitzpatrickSkinType = fitzpatrickSkinType.skinType
                attributes.append(Attribute(attributeType: "FitzpatrickSkinType", attributeValue: uwFitzpatrickSkinType.stringRepresentation))
            }
            
            if let wheelchairUse = try? healthKitStore.wheelchairUse() {
                let uwWheelchairUse = wheelchairUse.wheelchairUse
                attributes.append(Attribute(attributeType: "WheelchairUse", attributeValue: uwWheelchairUse.stringRepresentation))
            }

            return attributes
        }
    }
    

}

