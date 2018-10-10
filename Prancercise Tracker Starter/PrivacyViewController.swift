//
//  PrivacyViewController.swift
//  Health Data Reader-Writer
//
//  Created by Pramoda Majhi on 9/26/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Canvas
import ProgressHUD

class PrivacyViewController: UIViewController {
    let firstImageView = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel  = UILabel()
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var thirdView: UIView!
   
    
    fileprivate func setupLabels() {
       // titleLabel.backgroundColor = .red
        //bodyLabel.backgroundColor = .green
//        titleLabel.numberOfLines = 0
//        titleLabel.text = "Welcome to Company XYX=Z"
//        titleLabel.font = UIFont(name: "Futura", size: 34)
//        bodyLabel.numberOfLines = 0
//        bodyLabel.text = "Hello There! Thanks so much for downloading our brand new app and giving us a try. Make sure to leave us a good review in the AppStore."
//        firstImageView.image = UIImage(named: "Bitmap")
//        firstImageView.contentMode = .scaleAspectFill
        
       // firstImageView.animationDuration = 4
        //firstImageView.startAnimating()
//        UIView.animate(withDuration: 10, delay: 3, usingSpringWithDamping: 0, initialSpringVelocity: 0, options:.curveEaseOut, animations: {
//            self.firstImageView.alpha = 0
//           // self.firstImageView.transform = //self.firstImageView.transform.translatedBy(x: 0, y: 200)
//
////        })
//        UIView.animate(withDuration: 2.0, animations: {
//            self.firstImageView.center.y += self.view.bounds.width
//        })
       // self.animation(viewAnimation: firstImageView)
       // ProgressHUD.showSuccess("Done")
        //subView.startCanvasAnimation()
//        UIView.animate(withDuration: 1, delay: 1, options:.curveEaseOut, animations: {
//            self.firstImageView.center.x -= self.view.bounds.width
//            //self.view.layoutIfNeeded()
//        }, completion: nil)
        
        
    }
    func animatePrivacy() {
        firstView.startCanvasAnimation()
        thirdView.startCanvasAnimation()
    }
    
    private func animation(viewAnimation: UIView) {
        UIView.animate(withDuration: 2, animations: {
            viewAnimation.frame.origin.x = +viewAnimation.frame.width
        })
        { (_) in
            UIView.animate(withDuration: 2, delay: 1, options: [.curveEaseOut], animations: {
                viewAnimation.frame.origin.x -= viewAnimation.frame.width
            })
            
        }
    }
    
    fileprivate func setUpstackView() {
        let stackView = UIStackView(arrangedSubviews: [firstImageView,titleLabel,  bodyLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        //stackView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        view.addSubview(stackView)
        // enables autolayout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animatePrivacy()
      //setupLabels()
      //setUpstackView()
        
        
 
    }
    override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                animatePrivacy()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("View did appear called")
//
//        setupLabels()
//        //setUpstackView()
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:[.curveEaseInOut, .autoreverse], animations: {
//            self.titleLabel.transform = CGAffineTransform(translationX: -30, y: 0)
//
//        }) { (true) in
//
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.titleLabel.alpha = 0
//                self.titleLabel.transform = self.titleLabel.transform.translatedBy(x: 0, y: -200)
//
//            })
//        }
//
//        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.bodyLabel.transform = CGAffineTransform(translationX: -30, y: 0)
//
//        }) { (_) in
//
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                self.bodyLabel.alpha = 0
//                self.bodyLabel.transform = self.bodyLabel.transform.translatedBy(x: 0, y: -200)
//
//            })
//        }
    
//    }
    
    
}
