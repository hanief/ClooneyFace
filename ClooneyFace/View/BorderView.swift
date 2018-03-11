//
//  BorderView.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import UIKit

class BorderView: LayerView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.white.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: self.bounds).cgPath
        
        self.layer.addSublayer(yourViewBorder)
    }
}
