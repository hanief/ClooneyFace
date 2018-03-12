//
//  FaceObserved.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import Foundation
import UIKit

final class FaceObserved {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = FaceObserved()
    
    weak var delegate: FaceObservedDelegate?
    
    // MARK: Local Variable
    
    private var imageOrientation: UIImageOrientation {
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
    
    var previewImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didUpdatePreviewImage()
            }
        }
    }
    
    var portraits : [UIImage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didUpdatedDetection()
            }
        }
    }
    
    var clooneyConfidence = 0.5 {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didLoadClooney()
            }
        }
    }
    
    var lastPerson: Person?
    
    var persons: [Person] = [] {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didUpdatePerson()
            }
        }
    }
    
    public func stopLoading() {
        self.delegate?.didStopLoading()
    }
    
    public func startLoading() {
        self.delegate?.didStartLoading()
    }
}

protocol FaceObservedDelegate: class {
    func didUpdatedDetection()
    func didUpdatePerson()
    func didUpdatePreviewImage()
    func didStartLoading()
    func didStopLoading()
    func didLoadClooney()
}

