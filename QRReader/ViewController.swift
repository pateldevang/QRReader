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
    
    //Supported code types also included bar code reader
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    

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

