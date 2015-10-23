//
//  ViewController.swift
//  Beacon
//
//  Created by Jonathan Andy Lim on 10/23/2015.
//  Copyright © 2015 SourcePad. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, ApiControllerDelegate, GMSMapViewDelegate {

    enum HelpState: String {
        case Accident = "accident"
        case Default = "default"
        case Fire = "fire"
        case Flood = "water"
        case Calamity = "calamity"
        case Crime = "crime"
    }
    
    var mapView: GMSMapView!
    var helpers = NSArray()
    var searchHelpersTimer: NSTimer?
    
    let userCoordinate = COORDINATE_PHILSPORTS
    
    //MARK: - Lazy variables
    private lazy var panicButton: UIButton = {
        let button: UIButton = UIButton(type: .Custom)
        button.frame = CGRectMake((self.view.frame.width - 100.0)/2, self.view.frame.height - 100.0, 100.0, 100.0)
        button.setBackgroundImage(UIImage(named: "panic"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "okay"), forState: .Selected)
        button.setTitleColor(UIColor.blackColor(), forState: .Selected)
        button.setTitle("Help!", forState: .Normal)
        button.setTitle("Thanks!", forState: .Selected)
        button.addTarget(self, action: "panicButtonAction:", forControlEvents: .TouchUpInside)
        
        return button
    }()
    
    
    //MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Button methods
    func panicButtonAction(sender: AnyObject) {
        self.panicButton.selected = !self.panicButton.selected
        NSUserDefaults.standardUserDefaults().setBool(self.panicButton.selected, forKey: DEFAULTS_PANIC_BUTTON_IS_SELECTED)
        
        let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        print(deviceId)
        
        if self.panicButton.selected {
            if NSUserDefaults.standardUserDefaults().boolForKey(DEFAULTS_USER_DID_ASK_FOR_HELP) {
                ApiController.updateAskForHelpState("default", deviceId: deviceId, delegate: self)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: DEFAULTS_USER_DID_ASK_FOR_HELP)
                ApiController.askForHelp(deviceId: deviceId, coordinate: userCoordinate, state: "default", delegate: self)
            }
            
            // Present help selection
            let vc = HelpSelectionViewController()
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            self.presentViewController(vc, animated: true, completion: nil)

            // Start search helpers timer
            self.searchHelpersTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "searchHelpersTimerAction:", userInfo: nil, repeats: true)

        } else {
            // Reset help
            ApiController.updateAskForHelpState("safe", deviceId: deviceId, delegate: self)
        }
    }
    
    //MARK: - Private methods
    private func configureView() {
        let camera = GMSCameraPosition.cameraWithLatitude(userCoordinate.latitude,
            longitude: userCoordinate.longitude, zoom: 15)
        
        self.mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        self.mapView.delegate = self
        self.mapView.myLocationEnabled = true
        self.view = self.mapView
        
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImageWithColor(UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0))
        marker.position = CLLocationCoordinate2DMake(userCoordinate.latitude, userCoordinate.longitude)
        marker.map = self.mapView
        
        self.view.addSubview(self.panicButton)
        
        self.panicButton.selected = NSUserDefaults.standardUserDefaults().boolForKey(DEFAULTS_PANIC_BUTTON_IS_SELECTED)
        
        //------------------------------
        //  TIMER
        //------------------------------
        let _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateTimerAction:", userInfo: nil, repeats: true)

    }
    
    func updateTimerAction(timer: NSTimer) {
        print("Searching for someone to help.")
        ApiController.searchAreaToHelp(delegate: self)
    }

    func searchHelpersTimerAction(timer: NSTimer) {
        // Waiting for help to come
        if self.panicButton.selected {
            print("Waiting for help to come.")
            let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
            ApiController.searchHelpers(deviceId: deviceId, delegate: self)
            
        // Stop timer
        } else {
            self.searchHelpersTimer?.invalidate()
            self.searchHelpersTimer = nil
        }
    }

    func plotMarkersOnMap(dataArray: NSArray) {
        self.mapView.clear()
        
        for dataElement in dataArray {
            let dataDict = dataElement as! NSDictionary
            let lat = dataDict.objectForKey("latitude")?.doubleValue
            let lon = dataDict.objectForKey("longitude")?.doubleValue

            // Skip marker if same as user location
            let position = CLLocationCoordinate2DMake(lat!, lon!)
            if position.latitude == userCoordinate.latitude && position.longitude == userCoordinate.longitude {
                continue
            }
            
            let marker = CustomMarker()
            marker.position = CLLocationCoordinate2DMake(lat!, lon!)
            marker.deviceId = dataDict.objectForKey("device_id") as? String
            marker.state = dataDict.objectForKey("state") as? String
            marker.icon = GMSMarker.markerImageWithColor(UIColor.grayColor())
            
            if let state = HelpState(rawValue: marker.state!) {
                switch state {
                case .Accident:
                    marker.icon = UIImage(named: "accident")
                case .Default:
                    marker.icon = UIImage(named: "help")
                case .Calamity:
                    marker.icon = UIImage(named: "calamity")
                case .Crime:
                    marker.icon = UIImage(named: "crime")
                case .Fire:
                    marker.icon = UIImage(named: "fire")
                case .Flood:
                    marker.icon = UIImage(named: "water")
                }
            }
            
            marker.map = self.mapView
        }
        
        // Plot user marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(userCoordinate.latitude, userCoordinate.longitude)
        marker.icon = GMSMarker.markerImageWithColor(UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0))
        marker.map = self.mapView
        self.mapView.selectedMarker = marker
    }
    
    //MARK: - GMSMapView delegate
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        let alert = UIAlertController(title: "HELP!", message: "Do you want to help this person?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
            // Send help
            let customMarker = marker as! CustomMarker
            let toHelp = customMarker.deviceId!
            let fromHelp: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
            ApiController.sendHelp(toHelp, fromHelp: fromHelp, delegate: self)
        }
        let noAction = UIAlertAction(title: "Umm... No.", style: .Cancel) { (action) -> Void in
            
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        return false
    }
    
    //MARK: - API controller delegate
    func apiController(controller: ApiController, didFinishAskForHelpWithResponse response: AnyObject) {
        print("Did finish ask for help.")
    }
    
    func apiController(controller: ApiController, didFailAskForHelpWithError error: NSError) {
        print("Did fail ask for help.")
    }
    
    func apiController(controller: ApiController, didFinishSearchAreaToHelpWithResponse response: AnyObject) {
        print("Did finish search area to help.")
        
        let responseDict = response as! NSDictionary
        let dataArray = responseDict.objectForKey("data") as! NSArray
        self.plotMarkersOnMap(dataArray)
    }
    
    func apiController(controller: ApiController, didFailSearchAreaToHelpWithError error: NSError) {
        print("Did fail search area to help.")
    }
    
    func apiController(controller: ApiController, didFinishSendHelpWithResponse response: AnyObject) {
        print("Did finish send help.")

    }
    
    func apiController(controller: ApiController, didFailSendHelpWithError error: NSError) {
        print("Did fail send help.")

    }
    
    func apiController(controller: ApiController, didFinishSearchHelpersWithResponse response: AnyObject) {
        print("Did finish search helpers.")
        let responseDict = response as! NSDictionary
        let dataArray = responseDict.objectForKey("data") as! NSArray

        if dataArray.count > 0 {
            // If same number of helpers, don't show 'Keep Calm'
            if dataArray.count == self.helpers.count {
                return
            }
            
            self.helpers = dataArray
            
            // Display 'Keep Calm'
            let vc = KeepCalmViewController()
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func apiController(controller: ApiController, didFailSearchHelpersWithError error: NSError) {
        print("Did fail search helpers.")
    }
}

