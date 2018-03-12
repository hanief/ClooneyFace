//
//  CameraViewController.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Vision
import QuartzCore
import Alamofire
import SwiftyJSON
import Pulley

class CameraViewController: UIViewController, ARSKViewDelegate, ARSessionDelegate {
    
    let refreshRate: TimeInterval = 1.0
    
    @IBOutlet var sceneView: ARSKView!
    
    private var scanTimer: Timer?
    
    private var scannedFaceViews = [UIView]()
    
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    private var currentBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision face detection requests
    private let visionQueue = DispatchQueue(label: "com.ruminant.ClooneyFace.faceQueue")
    
    //get the orientation of the image that correspond's to the current device orientation
    private var imageOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .right
        case .landscapeRight: return .down
        case .portraitUpsideDown: return .left
        case .unknown: fallthrough
        case .faceUp: fallthrough
        case .faceDown: fallthrough
        case .landscapeLeft: return .up
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure and present the SpriteKit scene that draws overlay content.
        let overlayScene = SKScene()
        overlayScene.scaleMode = .aspectFill
        sceneView.delegate = self
        sceneView.presentScene(overlayScene)
        sceneView.session.delegate = self
        
//        self.toggleTorch(on: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        //scan for faces in regular intervals
        scanTimer = Timer.scheduledTimer(timeInterval: refreshRate, target: self, selector: #selector(scanForFaces), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scanTimer?.invalidate()
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc
    private func scanForFaces() {
        
        //remove the test views and empty the array that was keeping a reference to them
        _ = scannedFaceViews.map { $0.removeFromSuperview() }
        scannedFaceViews.removeAll()
        
        //get the captured image of the ARSession's current frame
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else { return }
        
        let image = CIImage(cvPixelBuffer: capturedImage)
        
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            
            if let faces = request.results as? [VNFaceObservation] {
                
                if faces.count > 0 {
                    let context = CIContext(options: nil)
                    
                    if let imageRef = context.createCGImage(image, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(capturedImage), height: CVPixelBufferGetHeight(capturedImage))) {
                        let theImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: .right)
                        
                        self.uploadToServer(theImage)
                    }
                    
                    DispatchQueue.main.async {
                        //                        FaceObserved.shared.portraits = faces.map{
                        //                            UIImage(ciImage: image.cropped(to: $0.boundingBox))
                        //                        }
                        
                        for face in faces {
                            let layerView = BorderView(from: face.boundingBox, to: self.sceneView.bounds)
                    
                            self.sceneView.addSubview(layerView)
                            
                            self.scannedFaceViews.append(layerView)
                            
                        }
                    }
                } else {
//                    DispatchQueue.main.async {
//                    if let drawerVC = self.parent as? PulleyViewController {
//                        drawerVC.setDrawerPosition(position: .collapsed, animated: true)
//                    }
//                    }
                }
                
            }
        }
        
        DispatchQueue.global().async {
            try? VNImageRequestHandler(ciImage: image, orientation: self.imageOrientation).perform([detectFaceRequest])
        }
        
        
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on // set on
                } else {
                    device.torchMode = .off // set off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    func uploadToServer(_ image: UIImage?) {
        FaceObserved.shared.startLoading()
        
        if image != nil {
            if let data = UIImageJPEGRepresentation(image!, 0.5) {
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(data, withName: "image", fileName: "test.jpg", mimeType: "image/jpeg")
                        multipartFormData.append("1".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "clooney")
                },
                    to: "http://adamfield.net/hack24/",
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    for (_, data) in json {
                                        if let confidence = data["confidence"].double {
                                            FaceObserved.shared.clooneyConfidence = confidence
                                        } else {
                                            FaceObserved.shared.clooneyConfidence = 0.0
                                        }
                                    }
                                }
                                
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                        
                        FaceObserved.shared.stopLoading()
                }
                )
                
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(data, withName: "image", fileName: "test.jpg", mimeType: "image/jpeg")
                },
                    to: "http://adamfield.net/hack24/",
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    for face in json["faces"].arrayValue {
                                        let metadata = face["metadata"]
                                        
                                        let newPerson = Person()
                                        newPerson.name = metadata["name"].stringValue
                                        newPerson.id = metadata["id"].stringValue
                                        newPerson.faceURL = metadata["face"].stringValue
                                        newPerson.website = metadata["website"].stringValue
                                        newPerson.twitter = metadata["twitter"].stringValue
                                        newPerson.linkedIn = metadata["linkedin"].stringValue
                                        newPerson.bio = metadata["bio"].stringValue
                                        
                                        if FaceObserved.shared.persons.filter({ (person) -> Bool in
                                            return person.id == newPerson.id
                                        }).count == 0 {
                                            FaceObserved.shared.lastPerson = FaceObserved.shared.persons.first
                                            FaceObserved.shared.persons = [newPerson]
                                        }
                                    }
                                }
                                
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                        
                        FaceObserved.shared.stopLoading()
                }
                )
            } else {
                debugPrint("data is nil")
            }
        } else {
            debugPrint("image is nil")
        }
    }
}
