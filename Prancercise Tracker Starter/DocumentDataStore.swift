//
//  HealthKitDocumentStore.swift
//  Health Data Reader-Writer
//
//  Created by Patrick Holmes on 8/2/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import HealthKit

class DocumentDataStore {
    class func saveCDAToHealthKit() {
        /*
         Load CDA from `Bundle`, transform into `Data` object, then create
         sample and save into HealthKit.
         */
        if let cdaURL = Bundle.main.url(forResource: "SummaryOfCare", withExtension: "xml") {
            let cdaData = try! Data(contentsOf: cdaURL)
            let date = Date()
            let cdaSample = try! HKCDADocumentSample(data: cdaData, start: date, end: date, metadata: nil)
            
            HKHealthStore().save(cdaSample) { success, error in
                if let error = error {
                    print("Error Saving Health Records: \(error.localizedDescription)")
                } else {
                    print("Successfully saved Health Records")
                }
            }
        }
    }
    
    class func getMostRecentDocument(completion: @escaping (Int?, Error?) -> Int?) {
        
        guard let cdaType = HKObjectType.documentType(forIdentifier: .CDA) else {
            fatalError("Unable to create a CDA document type.")
        }
        
        // var allDocuments = [HKDocumentSample]()
        
        /* let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        */
        
        let docQuery = HKDocumentQuery(documentType: cdaType,
                                        predicate: nil,                 // mostRecentPredicate,
                                        limit: HKObjectQueryNoLimit,    // limit,
                                        sortDescriptors: nil,           // [sortDescriptor]
                                        includeDocumentData: true) { (query, resultsOrNil, done, errorOrNil) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let results = resultsOrNil else {
                                                        completion(nil, errorOrNil)
                                                        return
                                                }
                                                
                                                completion(results.count, nil)
                                            }
        }
        
        HKHealthStore().execute(docQuery)
    }
}
