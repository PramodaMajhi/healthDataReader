//
//  SecurityViewController.swift
//  Health Data Reader-Writer
//
//  Created by Pramoda Majhi on 10/8/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Canvas

class SecurityViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var thirdView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateSecurity()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func animateSecurity() {
        firstView.startCanvasAnimation()
        thirdView.startCanvasAnimation()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSecurity()
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
