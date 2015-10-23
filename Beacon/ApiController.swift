//
//  ApiController.swift
//  Beacon
//
//  Created by Jonathan Andy Lim on 10/23/2015.
//  Copyright © 2015 SourcePad. All rights reserved.
//

import UIKit
import Alamofire

private var singleton: ApiController?


class ApiController: NSObject {

    var delegate: AnyObject?
    
    //MARK: - Private methods
    private class func getInstance() -> ApiController {
        if singleton == nil {
            return ApiController()
        }
        return singleton!
    }
    
    //MARK: - Public class methods
    class func askForHelp(deviceId deviceId: String, coordinate: CLLocationCoordinate2D, state: String, delegate: AnyObject) {
        let controller = self.getInstance()
        controller.delegate = delegate
        controller.startAskForHelp(deviceId: deviceId, coordinate: coordinate, state: state)
    }

    class func updateAskForHelpState(state: String, deviceId: String, delegate: AnyObject) {
        let controller = self.getInstance()
        controller.delegate = delegate
        controller.startUpdateAskForHelpState(state, deviceId: deviceId)
    }

    class func searchAreaToHelp(delegate delegate: AnyObject) {
        let controller = self.getInstance()
        controller.delegate = delegate
        controller.startSearchAreaToHelp()
    }

    class func searchHelpers(deviceId deviceId: String, delegate: AnyObject) {
        let controller = self.getInstance()
        controller.delegate = delegate
        controller.startSearchHelpers(deviceId)
    }

    class func sendHelp(toHelp: String, fromHelp: String, delegate: AnyObject) {
        let controller = self.getInstance()
        controller.delegate = delegate
        controller.startSendHelp(toHelp, fromHelp: fromHelp)
    }

    //MARK: - Request methods
    private func startAskForHelp(deviceId deviceId: String, coordinate: CLLocationCoordinate2D, state: String) {
        let params = [
            "latitude": "\(coordinate.latitude)",
            "longitude": "\(coordinate.longitude)",
            "state": state,
            "device_id": deviceId
        ]
        let parameter = ["device": params]
        
        print(parameter)
        // Show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let manager = Alamofire.Manager.sharedInstance
        manager.request(.POST, API_BASE_URL + API_PATH_ASK_HELP, parameters: parameter, encoding: .URL)
            .responseJSON(completionHandler: { (responseData: Response<AnyObject, NSError>) -> Void in
                print(responseData.request)
                print(responseData.response)
                
                switch responseData.result {
                case .Success(let data):
                    print(data)
                    if self.delegate!.respondsToSelector("apiController:didFinishAskForHelpWithResponse:") {
                        self.delegate!.apiController!(self, didFinishAskForHelpWithResponse: data)
                    }
                    
                case .Failure(let error):
                    print(error)
                    if self.delegate!.respondsToSelector("apiController:didFailAskForHelpWithError:") {
                        self.delegate!.apiController!(self, didFailAskForHelpWithError: error)
                    }
                }
                
                // Hide network indicator
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
    }

    private func startUpdateAskForHelpState(state: String, deviceId: String) {
        let params = [
            "state": state,
        ]
        let parameter = ["device": params]
        
        print(parameter)
        // Show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let manager = Alamofire.Manager.sharedInstance
        manager.request(.PATCH, API_BASE_URL + API_PATH_ASK_HELP + "/" + deviceId, parameters: parameter, encoding: .URL)
            .responseJSON(completionHandler: { (responseData: Response<AnyObject, NSError>) -> Void in
                print(responseData.request)
                print(responseData.response)
                
                switch responseData.result {
                case .Success(let data):
                    print(data)
                    if self.delegate!.respondsToSelector("apiController:didFinishUpdateAskForHelpStateWithResponse:") {
                        self.delegate!.apiController!(self, didFinishUpdateAskForHelpStateWithResponse: data)
                    }
                    
                case .Failure(let error):
                    print(error)
                    if self.delegate!.respondsToSelector("apiController:didFailUpdateAskForHelpStateWithError:") {
                        self.delegate!.apiController!(self, didFailUpdateAskForHelpStateWithError: error)
                    }
                }
                
                // Hide network indicator
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
    }
    
    private func startSearchAreaToHelp() {
        // Show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let manager = Alamofire.Manager.sharedInstance
        manager.request(.GET, API_BASE_URL + API_PATH_ASK_HELP, parameters: nil, encoding: .URL)
            .responseJSON(completionHandler: { (responseData: Response<AnyObject, NSError>) -> Void in
                print(responseData.request)
                print(responseData.response)
                
                switch responseData.result {
                case .Success(let data):
                    print(data)
                    if self.delegate!.respondsToSelector("apiController:didFinishSearchAreaToHelpWithResponse:") {
                        self.delegate!.apiController!(self, didFinishSearchAreaToHelpWithResponse: data)
                    }
                    
                case .Failure(let error):
                    print(error)
                    if self.delegate!.respondsToSelector("apiController:didFailSearchAreaToHelpWithError:") {
                        self.delegate!.apiController!(self, didFailSearchAreaToHelpWithError: error)
                    }
                }
                
                // Hide network indicator
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
    }

    private func startSearchHelpers(deviceId: String) {
        // Show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let manager = Alamofire.Manager.sharedInstance
        manager.request(.GET, API_BASE_URL + API_PATH_SEARCH_HELPERS + "/" + deviceId, parameters: nil, encoding: .URL)
            .responseJSON(completionHandler: { (responseData: Response<AnyObject, NSError>) -> Void in
                print(responseData.request)
                print(responseData.response)
                
                switch responseData.result {
                case .Success(let data):
                    print(data)
                    if self.delegate!.respondsToSelector("apiController:didFinishSearchHelpersWithResponse:") {
                        self.delegate!.apiController!(self, didFinishSearchHelpersWithResponse: data)
                    }
                    
                case .Failure(let error):
                    print(error)
                    if self.delegate!.respondsToSelector("apiController:didFailSearchHelpersWithError:") {
                        self.delegate!.apiController!(self, didFailSearchHelpersWithError: error)
                    }
                }
                
                // Hide network indicator
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
    }
    
    private func startSendHelp(toHelp: String, fromHelp: String) {
        let params = [
            "recipient_id": toHelp,
            "criminal_id": fromHelp
        ]
        let parameter = ["aid": params]
        
        print(parameter)
        // Show network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let manager = Alamofire.Manager.sharedInstance
        manager.request(.POST, API_BASE_URL + API_PATH_SEND_HELP, parameters: parameter, encoding: .URL)
            .responseJSON(completionHandler: { (responseData: Response<AnyObject, NSError>) -> Void in
                print(responseData.request)
                print(responseData.response)
                
                switch responseData.result {
                case .Success(let data):
                    print(data)
                    if self.delegate!.respondsToSelector("apiController:didFinishSendHelpWithResponse:") {
                        self.delegate!.apiController!(self, didFinishSendHelpWithResponse: data)
                    }
                    
                case .Failure(let error):
                    print(error)
                    if self.delegate!.respondsToSelector("apiController:didFailSendHelpWithError:") {
                        self.delegate!.apiController!(self, didFailSendHelpWithError: error)
                    }
                }
                
                // Hide network indicator
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
    }
}

//MARK: - Delegate
@objc protocol ApiControllerDelegate {
    
    optional func apiController(controller: ApiController, didFinishAskForHelpWithResponse response:AnyObject)
    optional func apiController(controller: ApiController, didFailAskForHelpWithError error:NSError)

    optional func apiController(controller: ApiController, didFinishUpdateAskForHelpStateWithResponse response:AnyObject)
    optional func apiController(controller: ApiController, didFailUpdateAskForHelpStateWithError error:NSError)

    optional func apiController(controller: ApiController, didFinishSearchAreaToHelpWithResponse response:AnyObject)
    optional func apiController(controller: ApiController, didFailSearchAreaToHelpWithError error:NSError)

    optional func apiController(controller: ApiController, didFinishSearchHelpersWithResponse response:AnyObject)
    optional func apiController(controller: ApiController, didFailSearchHelpersWithError error:NSError)

    optional func apiController(controller: ApiController, didFinishSendHelpWithResponse response:AnyObject)
    optional func apiController(controller: ApiController, didFailSendHelpWithError error:NSError)
}





