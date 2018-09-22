//
//  TransperencyViewController.swift
//  Health Data Reader-Writer
//
//  Created by Pramoda Majhi on 9/22/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class TransperencyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButton(_ sender: Any) {
        
        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
            print("Was successful from controller \(success)")
        }
        
        print("clicked start button")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PHRViewController")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
