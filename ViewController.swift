//
//  ViewController.swift
//  TestWowza
//
//  Created by Taco on 2018/7/23.
//  Copyright © 2018年 Taco. All rights reserved.
//

import UIKit
import WowzaGoCoderSDK

class ViewController: UIViewController, WOWZStatusCallback, WOWZVideoSink, WOWZAudioSink {
    
    
    
    

    let SDKSampleSavedConfigKey = "SDKSampleSavedConfigKey"
    let SDKSampleAppLicenseKey = "GOSK-6645-010F-17FF-84F1-B74C"
    let BlackAndWhiteEffectKey = "BlackAndWhiteKey"
    
    @IBOutlet weak var broadcastButton:UIButton!
    @IBOutlet weak var settingsButton:UIButton!
    @IBOutlet weak var switchCameraButton:UIButton!
    @IBOutlet weak var torchButton:UIButton!
    @IBOutlet weak var micButton:UIButton!
    
    var goCoder:WowzaGoCoder?
    var goCoderConfig:WowzaConfig!
    
    var receivedGoCoderEventCodes = Array<WOWZEvent>()
    
    var goCoderRegistrationChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
            self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
        }
        
        goCoderConfig = WowzaConfig()
        
        goCoderConfig.load(.preset1280x720)
        
        goCoderConfig.hostAddress = "192.168.0.154"
        goCoderConfig.portNumber = 1935
        goCoderConfig.applicationName = "FBHelper";
        goCoderConfig.streamName = "myStream";
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !goCoderRegistrationChecked {
            goCoderRegistrationChecked = true
            if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
                self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
            }
            else {
                // Initialize the GoCoder SDK
                if let goCoder = WowzaGoCoder.sharedInstance() {
                    self.goCoder = goCoder
                    
                    // Request camera and microphone permissions
                    WowzaGoCoder.requestPermission(for: .camera, response: { (permission) in
                        print("Camera permission is: \(permission == .authorized ? "authorized" : "denied")")
                    })
                    
                    WowzaGoCoder.requestPermission(for: .microphone, response: { (permission) in
                        print("Microphone permission is: \(permission == .authorized ? "authorized" : "denied")")
                    })
                    
                    
                    
                    
                    
                    self.goCoder?.register(self as WOWZAudioSink)
                    self.goCoder?.register(self as WOWZVideoSink)
                    self.goCoder?.config = self.goCoderConfig
                    
                    // Specify the view in which to display the camera preview
                    self.goCoder?.cameraView = self.view
                    
                    // Start the camera preview
                    self.goCoder?.cameraPreview?.start()
                }
                
                //self.updateUIControls()
                
            }
        }
    }
    
    @IBAction func didTapBroadcastButton(_ sender:AnyObject?) {
        // Ensure the minimum set of configuration settings have been specified necessary to
        // initiate a broadcast streaming session
        if let configError = goCoder?.config.validateForBroadcast() {
            self.showAlert("Incomplete Streaming Settings", error: configError as NSError)
        }
        else {
            // Disable the U/I controls
            
            if goCoder?.status.state == .running {
                goCoder?.endStreaming(self)
            }
            else {
                receivedGoCoderEventCodes.removeAll()
                goCoder?.startStreaming(self)
                
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Alerts
    
    func showAlert(_ title:String, status:WOWZStatus) {
        let alertController = UIAlertController(title: title, message: status.description, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(_ title:String, error:NSError) {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func videoFrameWasCaptured(_ imageBuffer: CVImageBuffer, framePresentationTime: CMTime, frameDuration: CMTime) {
        
       
    }
    
    func onWOWZStatus(_ status: WOWZStatus!) {
        
        switch (status.state) {
        case .idle:
            DispatchQueue.main.async { () -> Void in
                
            }
            
        case .running:
            DispatchQueue.main.async { () -> Void in
                
            }
        case .stopping, .starting:
            DispatchQueue.main.async { () -> Void in
                // self.updateUIControls()
            }
            
        case .buffering: break
        default: break
        }
    }
    
    func onWOWZError(_ status: WOWZStatus!) {
        
        DispatchQueue.main.async { () -> Void in
            if !self.receivedGoCoderEventCodes.contains(status.event) {
                self.receivedGoCoderEventCodes.append(status.event)
                self.showAlert("Live Streaming Event", status: status)
            }
            
            //self.updateUIControls()
        }
        
        
    }
}

