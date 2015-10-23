//
//  HelpSelectionViewController.swift
//  Beacon
//
//  Created by Jonathan Andy Lim on 10/23/2015.
//  Copyright © 2015 SourcePad. All rights reserved.
//

import UIKit

class HelpSelectionViewController: UIViewController, ApiControllerDelegate {

    enum ButtonTag: Int {
        case Accident = 0, Fire, Calamity, Water, Crime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func configureView() {
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        
        //------------------------------
        //  Buttons
        //------------------------------
        let accidentBtn = UIButton(type: .Custom)
        accidentBtn.frame = CGRectMake(0, 0, self.view.frame.width/2, (self.view.frame.height - 50.0)/3)
        accidentBtn.setImage(UIImage(named: "accident-btn"), forState: .Normal)
        accidentBtn.addTarget(self, action: "stateButtonAction:", forControlEvents: .TouchUpInside)
        accidentBtn.tag = ButtonTag.Accident.rawValue

        let fireBtn = UIButton(type: .Custom)
        fireBtn.frame = CGRectMake(accidentBtn.frame.maxX, 0, self.view.frame.width/2, (self.view.frame.height - 50.0)/3)
        fireBtn.setImage(UIImage(named: "fire-btn"), forState: .Normal)
        fireBtn.addTarget(self, action: "stateButtonAction:", forControlEvents: .TouchUpInside)
        fireBtn.tag = ButtonTag.Fire.rawValue

        let calamityBtn = UIButton(type: .Custom)
        calamityBtn.frame = CGRectMake(0, accidentBtn.frame.maxY, self.view.frame.width/2, (self.view.frame.height - 50.0)/3)
        calamityBtn.setImage(UIImage(named: "calamity-btn"), forState: .Normal)
        calamityBtn.addTarget(self, action: "stateButtonAction:", forControlEvents: .TouchUpInside)
        calamityBtn.tag = ButtonTag.Calamity.rawValue

        let waterBtn = UIButton(type: .Custom)
        waterBtn.frame = CGRectMake(calamityBtn.frame.maxX, accidentBtn.frame.maxY, self.view.frame.width/2, (self.view.frame.height - 50.0)/3)
        waterBtn.setImage(UIImage(named: "water-btn"), forState: .Normal)
        waterBtn.addTarget(self, action: "stateButtonAction:", forControlEvents: .TouchUpInside)
        waterBtn.tag = ButtonTag.Water.rawValue

        let crimeBtn = UIButton(type: .Custom)
        crimeBtn.frame = CGRectMake(0, calamityBtn.frame.maxY, self.view.frame.width/2, (self.view.frame.height - 50.0)/3)
        crimeBtn.setImage(UIImage(named: "crime-btn"), forState: .Normal)
        crimeBtn.addTarget(self, action: "stateButtonAction:", forControlEvents: .TouchUpInside)
        crimeBtn.tag = ButtonTag.Crime.rawValue
        
        // Close button
        let closeButton = UIButton(type: .RoundedRect)
        closeButton.frame = CGRectMake(0, self.view.frame.height - 50.0, self.view.frame.width, 50.0)
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.addTarget(self, action: "closeButtonAction:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(accidentBtn)
        self.view.addSubview(fireBtn)
        self.view.addSubview(calamityBtn)
        self.view.addSubview(waterBtn)
        self.view.addSubview(crimeBtn)
        self.view.addSubview(closeButton)
    }
    
    func closeButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stateButtonAction(sender: AnyObject) {
        if let button = sender as? UIButton {
            var helpState = ""

            if let state = ButtonTag(rawValue: button.tag) {
                switch state {
                case .Accident:
                    helpState = "accident"
                case .Calamity:
                    helpState = "calamity"
                case .Crime:
                    helpState = "crime"
                case .Fire:
                    helpState = "fire"
                case .Water:
                    helpState = "water"
                    
                }
            }
            
            // Update ask for help state
            let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
            ApiController.updateAskForHelpState(helpState, deviceId: deviceId, delegate: self)
        }
    }
    
    //MARK: - API controller delegate
    func apiController(controller: ApiController, didFinishUpdateAskForHelpStateWithResponse response: AnyObject) {
        print("Did finish update ask for help state.")
        self.closeButtonAction(self)
    }
    
    func apiController(controller: ApiController, didFailUpdateAskForHelpStateWithError error: NSError) {
        print("Did fail update ask for help state.")
    }
}
