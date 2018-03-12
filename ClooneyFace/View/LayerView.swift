//
//  LayerView.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import UIKit
import Spring

class LayerView: SpringView {

    convenience init(from boundingBox: CGRect, to sceneBounds: CGRect) {
        self.init(frame: LayerView.faceFrame(from: boundingBox, to: sceneBounds))
    }
    
    public static func faceFrame(from boundingBox: CGRect, to sceneBounds: CGRect) -> CGRect {
        
        //translate camera frame to frame inside the Scene View
        let origin = CGPoint(x: boundingBox.minX * sceneBounds.width, y: (1 - boundingBox.maxY) * sceneBounds.height)
        let size = CGSize(width: boundingBox.width * sceneBounds.width, height: boundingBox.height * sceneBounds.height)
        
        return CGRect(origin: origin, size: size)
    }
    
    public func bobble() {
    
    }
    
    private func animateLeft() {
        UIView.animate(withDuration: 1.0, animations: {
            
        }) { (completed) in
            if completed {
                
            }
        }
    }
    
    private func animateRight() {
        
    }
}
