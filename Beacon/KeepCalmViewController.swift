//
//  KeepCalmViewController.swift
//  Beacon
//
//  Created by Jonathan Andy Lim on 10/23/2015.
//  Copyright © 2015 SourcePad. All rights reserved.
//

import UIKit

class KeepCalmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       // Do any additional setup after loading the view.
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        
        let imageView = UIImageView(image: UIImage(named: "keepcalm"))
        imageView.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        
        blurEffectView.contentView.addSubview(imageView)

        // Close button
        let closeButton = UIButton(type: .RoundedRect)
        closeButton.frame = CGRectMake(0, self.view.frame.height - 50.0, self.view.frame.width, 50.0)
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.addTarget(self, action: "closeButtonAction:", forControlEvents: .TouchUpInside)

        self.view.addSubview(closeButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func closeButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}
