//
//  TransperencyViewController.swift
//  Health Data Reader-Writer
//
//  Created by Pramoda Majhi on 9/22/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Canvas

class TransperencyViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animateTransperency()
        fourthView.alpha = 0
        fourthView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func animateTransperency() {
        firstView.startCanvasAnimation()
        thirdView.startCanvasAnimation()
        fourthView.startCanvasAnimation()
        fourthView.alpha = 1
        fourthView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateTransperency()
    }
    
    @IBAction func startButton(_ sender: Any) {
        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
            print("Was successful from controller \(success)")
        }
       
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
