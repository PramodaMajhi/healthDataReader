//
//  PHRViewController.swift
//  Health Data Reader-Writer
//
//  Created by Pramoda Majhi on 9/4/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import HealthKit

class PHRViewController: UIViewController {

   // @IBOutlet var mainbutton: UIButton!
    
    
    @IBAction func sendData(_ sender: Any) {
         uploadHealthRecord()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
//            print("Was successful from controller \(success)")
//        }
//        mainbutton.layer.shadowRadius = 4
//        mainbutton.layer.cornerRadius = mainbutton.frame.height/2
//        mainbutton.layer.shadowOffset = CGSize(width: 0, height: 0)
//        mainbutton.layer.shadowOpacity = 0.5
       // mainbutton.backgroundColor = UIColor.darkGray
       // mainbutton.setTitleColor(UIColor.white, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func uploadHealthRecord() {
        let hdu = HealthDataUploader()
        hdu.getDataAndUpload()
    }

    

}
