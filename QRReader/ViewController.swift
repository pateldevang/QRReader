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
    
    var video = AVCaptureVideoPreviewLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Define session
        let session = AVCaptureSession()
        
        //Define capture device
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            //IF sucess
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            //Generate error
            print("ERROR")
        }
        
        // Output set to METAdataOutput
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        // OUtput set to Main thread for better performance
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Output type set to QR
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        //Video session added to sublayer
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        // session running for AVCapture
        session.startRunning()
        
    }


}

