//
//  ClooneyView.swift
//  ClooneyFace
//
//  Created by Hanief on 11/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import UIKit
import Spring

class ClooneyView: LayerView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let clooneyView = UIImageView(image: UIImage(named: "clooney"))
        clooneyView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.addSubview(clooneyView)
        
    }
    
    
}
