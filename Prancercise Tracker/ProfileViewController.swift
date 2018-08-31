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

class ProfileViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
            print("Was successful from controller \(success)")
        }
       
    }
    
  private enum ProfileSection: Int {
    case ageSexBloodType
    case weightHeightBMI
    case BPM
    case readHealthKitData
  }
  
  private enum ProfileDataError: Error {
    
    case missingBodyMassIndex
    
    var localizedDescription: String {
      switch self {
      case .missingBodyMassIndex:
        return "Unable to calculate body mass index with available profile data."
      }
    }
  }
  
  @IBOutlet private var ageLabel:UILabel!
  @IBOutlet private var bloodTypeLabel:UILabel!
  @IBOutlet private var biologicalSexLabel:UILabel!
  @IBOutlet private var weightLabel:UILabel!
  @IBOutlet private var heightLabel:UILabel!
  @IBOutlet private var bodyMassIndexLabel:UILabel!
  
  @IBOutlet var bpmLable: UILabel!
  
  @IBOutlet var restingHRLabel: UILabel!
    
    
    
    private let userHealthProfile = UserHealthProfile()
  
  private func updateHealthInfo() {
    loadAndDisplayAgeSexAndBloodType()
    loadAndDisplayMostRecentWeight()
    loadAndDisplayMostRecentHeight()
    loadAndDisplayheartRate()
    loadAndDisplayRestingheartRate()
    loadAndDisplayheartRateVariability()
    loadAndDisplayStepCount()
    loadAndDisplaySleepHours()
   // onPostData(healthData: userHealthProfile)
    print("data read and displayed")
  }
  
  private func loadAndDisplayAgeSexAndBloodType() {
    let userAgeSexAndBloodType = ProfileDataStore.getAgeSexAndBloodType()
    userHealthProfile.age = userAgeSexAndBloodType.age
    userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
    userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
    updateLabels()
  }
  
  private func loadAndDisplayMostRecentHeight() {
    //1. Use HealthKit to create the Height Sample Type
    guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
        print("Height Sample Type is no longer available in HealthKit")
        return
    }
    
    ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
        
        guard let sample = sample else {
            
            if let error = error {
                self.displayAlert(for: error)
            }
            
            return
        }
        
        //2. Convert the height sample to meters, save to the profile model,
        //   and update the user interface.
        let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
        self.userHealthProfile.heightInMeters = heightInMeters
        self.updateLabels()
    }
  }
  
  private func loadAndDisplayMostRecentWeight() {
    guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
        print("Body Mass Sample Type is no longer available in HealthKit")
        return
    }
    
    ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
        
        guard let sample = sample else {
            
            if let error = error {
                self.displayAlert(for: error)
            }
            return
        }
        
        let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
        self.userHealthProfile.weightInKilograms = weightInKilograms
        self.updateLabels()
    }
  }
    
// reading heart rate
    private func loadAndDisplayheartRate() {
        //1. Use HealthKit to create the Heart Rate Sample Type
        guard  let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("heart rate not avaialble from HealthKit")
            return
        }
        
       // let heartRateUnit = HKUnit(from: "count/min")
        ProfileDataStore.getMostRecentSample(for: heartRateType) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            //2. Convert the heart rate sample ,
            //   and update the user interface.
            
            
            //let value = sample.quantity.doubleValue(for: heartRateUnit)
            //self.userHealthProfile.heartRate = String(value)
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let heartRateString = String(format: "%.00f", value)
            self.userHealthProfile.heartRate = heartRateString
            self.updateLabels()
            
        }
    }
// end of reading heart rate
    
// Reading resting heart
    // reading heart rate
    private func loadAndDisplayRestingheartRate() {
        //1. Use HealthKit to create the Heart Rate Sample Type
        guard  let restingHeartRate: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("resting heart rate not avaialble from HealthKit")
            return
        }
        
        // let heartRateUnit = HKUnit(from: "count/min")
        ProfileDataStore.getMostRecentSample(for: restingHeartRate) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            //2. Convert the heart rate sample ,
            //   and update the user interface.
            
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let restingheartRateString = String(format: "%.00f", value)
            self.userHealthProfile.restingHeartRate = restingheartRateString
            self.updateLabels()
            //ProfileDataStore.testSourceQuery()
            //ProfileDataStore.getFitness()
            //ProfileDataStore.retrieveSleepAnalysis()
            
        }
    }
    // end of reading heart rate
// end
    
    // Reading resting heart variability

    private func loadAndDisplayheartRateVariability() {
        //1. Use HealthKit to create the Heart Rate Sample Type
        guard  let heartRateVariabilitySDNN: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("heart rate variability not avaialble from HealthKit")
            return
        }
        
        // let heartRateUnit = HKUnit(from: "count/min")
        ProfileDataStore.getMostRecentSample(for: heartRateVariabilitySDNN) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            //2. Convert the heart rate sample ,
            //   and update the user interface.
            let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            let heartRateVarString = String(format: "%.00f", value)
            self.userHealthProfile.heartRateVariabilitySDNN = heartRateVarString
            self.updateLabels()
            
        }
    }
    // end of reading heart rate variability
    
    
    
    // Reading step count
    private func loadAndDisplayStepCount() {
        
        //1. Use HealthKit read step count
     guard  let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
           print("step count is not avaialble from HealthKit")
           return
        }
        
        ProfileDataStore.getTodaysSteps(for: stepsQuantityType) { (steps, sample, error) in
            guard let steps  = steps else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            
            print("steps count found : \(steps)")
            let stepCountString = String(format: "%.00f", steps)
            self.userHealthProfile.stepCount = stepCountString
            self.updateLabels()
            
        }
    }
    // end of reading stepcount
    
    // Reading sleep analysis
    private func loadAndDisplaySleepHours() {
        
        ProfileDataStore.retrieveSleepAnalysis { (sample, error) in
            guard let sample  = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            let seconds = sample.endDate.timeIntervalSince(sample.startDate)
            let  (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Int(seconds))
            print ("\(h) Hours, \(m) Minutes, \(s) Seconds")
        }
    }
    // end of reading stepcount
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
  
    private func updateLabels() {
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }
        
        if let biologicalSex = userHealthProfile.biologicalSex {
            biologicalSexLabel.text = biologicalSex.stringRepresentation
        }
        
        if let bloodType = userHealthProfile.bloodType {
            bloodTypeLabel.text = bloodType.stringRepresentation
        }
        
        if let weight = userHealthProfile.weightInKilograms {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            weightLabel.text = weightFormatter.string(fromKilograms: weight)
        }
        
        if let height = userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            heightLabel.text = heightFormatter.string(fromMeters: height)
        }
        
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bodyMassIndexLabel.text = String(format: "%.02f", bodyMassIndex)
        }
        if let heartRate = userHealthProfile.heartRate {
            bpmLable.text =  heartRate + " bpm"
            print("Heart Rate \(heartRate)")
        }
        if let restingHeartRate = userHealthProfile.restingHeartRate {
            restingHRLabel.text =  restingHeartRate + " bpm"
            print("Resting Heart Rate \(restingHeartRate)")
            
        }
        if let heartRateVar = userHealthProfile.heartRateVariabilitySDNN {
            //restingHRLabel.text =  heartRateVar + " bpm"
            print("Heart Rate variability \(heartRateVar) ms")
            
        }
        
        if let stepCount = userHealthProfile.stepCount {
            print("steps count \(stepCount)")
        }
        if let sleepHours = userHealthProfile.sleepHours {
            print("sleep hours \(sleepHours)")
        }
    }
    
    
    func onPostData(healthData: UserHealthProfile) {
        print("healthData \(healthData)")
        let age = healthData.age!
        print("profile \(age)")
        //var json = JSONS
        
        let parameters = ["username": "@blueshield","heartRataType": "150bpm"]
        guard let url = URL(string:"https://jsonplaceholder.typicode.com/posts") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let  httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                }catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    
 
  private func displayAlert(for error: Error) {
    
    let alert = UIAlertController(title: nil,
                                  message: error.localizedDescription,
                                  preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "O.K.",
                                  style: .default,
                                  handler: nil))
    
    present(alert, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let section = ProfileSection(rawValue: indexPath.section) else {
      fatalError("A ProfileSection should map to the index path's section")
    }
    
    switch section {
    case .readHealthKitData:
        updateHealthInfo()
    default: break
    }
  }
}
