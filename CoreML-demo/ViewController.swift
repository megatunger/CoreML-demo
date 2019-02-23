//
//  ViewController.swift
//  CoreML-demo
//
//  Created by Hoang Son Tung on 2/20/19.
//  Copyright © 2019 Hoang Son Tung. All rights reserved.
//

import UIKit
import AVKit
import Vision

var resultPrediction: String!

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var BlurView: UIVisualEffectView!
    
    @IBOutlet weak var LabelClassify: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create AVCaptureDevice for media type video (camera)
        guard let camera = AVCaptureDevice.default(for: .video),
            // Create input source for device camera
            let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
                return
        }
        
        //Create object for AVCaptureSession class. This object will handle capture input flow. In here, we need to capture images from iPhone camera
        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
        
        //Add input source into session
        captureSession.addInput(cameraInput)
        
        //Run the session and capture video
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewView.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
    }

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame: ", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model)
        {(finishedReq, err) in
            //Perhaps check the err
            
//            print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            
            //print(firstObservation.identifier, firstObservation.confidence)
            resultPrediction = firstObservation.identifier
            print(resultPrediction)
            DispatchQueue.main.async {
                self.LabelClassify.text = resultPrediction
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

