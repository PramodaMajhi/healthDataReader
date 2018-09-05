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

import UIKit
import HealthKit
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
    
  let healthStore:HKHealthStore = HKHealthStore()
  var observeQuery: HKObserverQuery!
    
    func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
        }
        
        healthStore.execute(query)
    }
    
    func observerHeartRateSamples() {
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
       if let observeQuery = observeQuery {
               healthStore.stop(observeQuery)
        }
        
         observeQuery  = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestHeartRateSample { (sample) in
                guard let sample = sample else {
                    return
                }
                
                DispatchQueue.main.async {
                   // let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    let heartRateString = String(format: "%.00f", value)
                    print("Heart Rate Sample: \(value)")
                   self.updateHeartRate(heartRateValue: heartRateString)
                    
                }
            }
        }
        
        healthStore.execute(observeQuery)
    }
    
    func updateHeartRate(heartRateValue: String) {
        print("Method called happened inside delegate")
        healthStore.enableBackgroundDelivery(for: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!, frequency: HKUpdateFrequency.immediate) { (success, error) in
            if success{
                print("success")
            } else {
                print("fail")
            }
        }
    }
    
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
   // let hdu = HealthDataUploader()
   // hdu.getDataAndUpload()
    return true
  }
}

