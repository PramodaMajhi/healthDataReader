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

import Foundation

import UIKit

class MasterViewController: UITableViewController {
  
    private enum Section: Int {
        case viewHealthData
        case spacer
        case authorizeHealthKitSection
        case importHealthRecord
        case viewHealthRecords
        case uploadHealthRecord
    }
    
    private func authorizeHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
        
        guard authorized else {
            
            let baseMessage = "HealthKit Authorization Failed"
            
            if let error = error {
                print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
                print(baseMessage)
            }
            
            return
        }
        
        print("HealthKit Successfully Authorized.")
        }
    }
  
    private func importHealthRecord() {
        DocumentDataStore.saveCDAToHealthKit()
        print("Imported document")
    }
    private func viewHealthRecords() {
        DocumentDataStore.getMostRecentDocument { (count, error) in
            
            return nil
        }
        print("View healt record")
    }
    
    private func uploadHealthRecord() {
        let hdu = HealthDataUploader()
        hdu.getDataAndUpload()       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("A Section should map to the index path's section")
        }
        
        switch section {
            case .authorizeHealthKitSection:
                authorizeHealthKit()
            case .importHealthRecord:
                importHealthRecord()
            case .viewHealthRecords:
                viewHealthRecords()
            case .uploadHealthRecord:
                uploadHealthRecord()
            default: break
        }
    }    
  
}
