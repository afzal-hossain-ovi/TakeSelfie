//
//  TakeSelfieViewController.swift
//  TakeSelfie
//
//  Created by Afzal Hossain on 09.06.21.
//

import UIKit
import Vision
import AVKit

open class TakeSelfieViewController: UIViewController {

    // AVCapture variables to hold sequence data
    public let session = AVCaptureSession()
    public var previewLayer: AVCaptureVideoPreviewLayer! = nil
    public let videoDataOutput = AVCaptureVideoDataOutput()
    
    public var rootLayer: CALayer! = nil
    public var textOverlay: CALayer! = nil
    
    // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
    // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
    public let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // oval overlay in the centre of the screen to indicate to the user where to position their face
    public let overlayView = OvalOverlayView()
    
    // CIDetector object will find face
    public let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                             context: nil,
                                             options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    // check image saved successfully
    public var captureImage: ((_ image: UIImage?)-> Void)? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAVCapture()
        startCaptureSession()
        setupLayers()
    }
    
    deinit {
        teardownAVCapture()
    }
    
    public func setupLayers() {
        textOverlay = CALayer() // container layer that has all the renderings of the observations
        textOverlay.name = "OverlayText"
        textOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: 300,
                                         height: 30)
        textOverlay.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        rootLayer.addSublayer(textOverlay)
    }
    
    // MARK:- AVCapture Setup
    
    public func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            session.addOutput(videoDataOutput)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.videoOrientation = .portrait
        
        session.commitConfiguration()
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        rootLayer = view.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        view.addSubview(overlayView)
    }
    
    public func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    public func teardownAVCapture() {
        session.stopRunning()
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
}

// MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
// Handle delegate method callback on receiving a sample buffer.
extension TakeSelfieViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput,
                                  didOutput sampleBuffer: CMSampleBuffer,
                                  from connection: AVCaptureConnection) {
        
        
        if output == videoDataOutput {
            self.deviceOrientation(from: connection)
            
            guard let (faceCIImage, faceUIImage) = self.createFaceImages(sampleBuffer: sampleBuffer) as? (CIImage, UIImage) else {
                print("couldn't create face image")
                return
            }
            
            
            let options = [CIDetectorImageOrientation: self.orientation(orientation: UIDevice.current.orientation),CIDetectorSmile: true,CIDetectorEyeBlink: true] as [String: Any]
            guard let features = faceDetector?.features(in: faceCIImage, options: options) else {
                print("face features empty")
                return
            }
            
            self.handleFaceFeatures(features: features,
                                            faceImage: faceCIImage,
                                            faceUIImage: faceUIImage)
        }
    }
}


//MARK:- Helper method to create face features and images
extension TakeSelfieViewController {
    
    // create face images using caputre output sample buffer
    public func createFaceImages(sampleBuffer: CMSampleBuffer) -> (CIImage?, UIImage?) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return (nil, nil)
        }
        let faceCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let faceImage = context.createCGImage(faceCIImage, from: CGRect(x: 0,y: 0,width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))) else {
            return (nil, nil)
        }
        let faceUIImage = UIImage(cgImage: faceImage,scale: 0.0,orientation: .up)
        return (faceCIImage, faceUIImage)
    }
    
    // using CIFeature cheacking detected face inside the overlay
    public func handleFaceFeatures(features: [CIFeature],
                                            faceImage: CIImage,
                                            faceUIImage: UIImage) {
        guard let features = features as? [CIFaceFeature] else {
            return
        }
        if features.isEmpty || features.count > 2 {
            return
        }
        let faceFeature = features[0]
        print(faceFeature.rightEyeClosed)
        print(faceFeature.leftEyeClosed)
        print(faceFeature.bounds)
        
        DispatchQueue.main.async {
            self.textOverlay.sublayers = nil
            if faceFeature.leftEyeClosed || faceFeature.rightEyeClosed {
                let textLayer = self.createTextSubLayerInBounds(self.overlayView.ovalOverlay, identifier: "Closed Eyes")
                self.textOverlay.addSublayer(textLayer)
            }
        }
        
        if (overlayView.ovalOverlay.width + 100) >= faceFeature.bounds.width && overlayView.ovalOverlay.height >= faceFeature.bounds.height{
            print("Face inside the overlay")
            self.session.stopRunning()
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(faceUIImage,self,#selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc public func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            captureImage?(nil)
        } else {
            captureImage?(image)
        }
    }
}

extension TakeSelfieViewController {
    
    public func deviceOrientation(from connection: AVCaptureConnection!) {
        //Correct video orientation from device orientation
        switch UIDevice.current.orientation {
                  case .landscapeRight:
                      connection.videoOrientation = .landscapeLeft
                  case .landscapeLeft:
                      connection.videoOrientation = .landscapeRight
                  case .portrait:
                      connection.videoOrientation = .portrait
                  case .portraitUpsideDown:
                      connection.videoOrientation = .portraitUpsideDown
                  default:
                      connection.videoOrientation = .portrait //Make `.portrait` as default
        }
    }
    
    
    public func orientation(orientation: UIDeviceOrientation) -> Int {
        switch orientation {
            case .portraitUpsideDown:
                return 8
            case .landscapeLeft:
                return 3
            case .landscapeRight:
                return 1
            case .portrait:
                return 6
            default:
                return 6
        }
    }
    
    public func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)"))
        let largeFont = UIFont(name: "Helvetica", size: 20.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont, NSAttributedString.Key.foregroundColor : UIColor.red], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.contentsScale = 2.0 // retina rendering
        return textLayer
    }
}
