//
//  ViewController.swift
//  Bring Me Fries
//
//  Created by katia on 11/5/15.
//  Copyright (c) 2015 katia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var firstImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstImageView = UIImageView(image: UIImage (named: "arrow.png"))
        firstImageView.center = view.center
        view.addSubview(firstImageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        firstImageView.alpha = 0.0
        firstImageView.transform = CGAffineTransformIdentity
        imageFadeIn(firstImageView)
    }
    
    func imageFadeIn(imageView: UIImageView) {
        
        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseOut, animations: {
            imageView.alpha = 1.0
            imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }, completion: nil
        )}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ItemViewController: UIViewController {
    
}