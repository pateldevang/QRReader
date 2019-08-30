//
//  ViewController.swift
//  QRReader
//
//  Created by Devang Patel on 25/08/19.
//  Copyright © 2019 Devang Patel. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var QRimageView: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    
    
    // AVCaputure seesion initialise
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide scan button
        scanButton.isHidden = true
        
        //Add scanner to subView
        view.addSubview(scannerView)
       
        scan()
        viewAnimate(till: true)
      
    }
    
    
    func moveUp(view: UIView) {
        view.center.y -= QRimageView.frame.height - 20.0
    }
    
    func moveDown(view: UIView) {
        view.center.y += QRimageView.frame.height - 20.0
    }
    
    func viewAnimate(till: Bool) {
        
         view.addSubview(scannerView)
        
        if till == true {
            
            let duration: Double = 1.6
            UIView.animate(withDuration: duration, animations: {
                self.moveDown(view: self.scannerView)
                
            }) { (finished) in
                if finished {
                    UIView.animate(withDuration: duration, animations: {
                        self.moveUp(view: self.scannerView)
                    }, completion: { (finished) in
                        if finished {
                             //call func viewAnimate recursive
                            self.viewAnimate(till: true)
                        }
                    })
                }
            }
        }
        
    }
    
    
    //MARK:- Scan start function
    
    func scan() {
        
//        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
//        self.view.addGestureRecognizer(pinchRecognizer)
        
        // Unhide ScannerView
        scannerView.isHidden = false
        
        // Retake button hide
        scanButton.isHidden = true
        
        //Change QR frame image
        QRimageView.image = UIImage(named: "Focus")
        
        view.backgroundColor = UIColor.black
        //AV session
        captureSession = AVCaptureSession()
        
        //AV Caputre Device confige
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            //failed func
            failed()
            return
        }
        
        // MetaData handler
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        //View setting
        view.layer.addSublayer(previewLayer)
        view.addSubview(QRimageView)
        view.addSubview(scanButton)
        
        // Finally run capture session
        captureSession.startRunning()
    }
    
    //MARK:- Failed error generating function

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            // This part of code is written because app will crash the capture-session when the view initial with no inputs
            captureSession.stopRunning()
        }
    }
    
    
    // MetaData Output handler
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        //AV session stop after input is generated comment out if you need to scan continouly
        captureSession.stopRunning()
        
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Vibration genrated if QR code detected
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Change QR imageView after QR is detected
            QRimageView.image = UIImage(named: "QR")
            
            // Hide ScannerView
            self.scannerView.isHidden = true
            
            // Unhide retake button
            self.scanButton.isHidden = false
            
            // Write your code here to use the generated output
            found(code: stringValue) //Example written here
            // TO generate alert
            alert(url: stringValue, code: stringValue)
        }
    }
    
    //MARK:- Found function to print output in debug console
    func found(code: String) {
        print(code)
    }
    
    // Optional we want to hide the status bar otherwise comment it out
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Setting up portrait orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK:- Scan button can be used if user need to scan the code manually
    @IBAction func scanAction(_ sender: UIButton) {
        scan()
        scannerView.center.y = 179.0
        viewAnimate(till: true)
    }
    
    
    //MARK:- Alert function
    
    func alert(url: String, code: String) {
        let alert = UIAlertController(title: "QR Code detcted", message: code, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: { (nil) in
            self.scan()
        }))
        alert.addAction(UIAlertAction(title: "Open URL", style: .default, handler: { (nil) in
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }))
        present(alert,animated: true,completion: nil)
    }
    
//
//    func pinch(_pinch: UIPinchGestureRecognizer) {
//        var device: AVCaptureDevice = self.videoDevice
//        var vZoomFactor = ((UIGestureRecognizer() as! UIPinchGestureRecognizer).scale)
//        var error:NSError!
//        do{
//            try device.lockForConfiguration()
//            defer {device.unlockForConfiguration()}
//            if (vZoomFactor <= device.activeFormat.videoMaxZoomFactor){
//                device.videoZoomFactor = vZoomFactor
//            }else{
//                NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor);
//            }
//        }catch error as NSError{
//            NSLog("Unable to set videoZoom: %@", error.localizedDescription);
//        }catch _{
//
//        }
//    }
    
    //Get the device (Front or Back)
//    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
//        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
//        for de in devices {
//            let deviceConverted = de as! AVCaptureDevice
//            if(deviceConverted.position == position){
//                return deviceConverted
//            }
//        }
//        return nil
//    }
    
}

