//
//  OvalOverlayView.swift
//  TakeSelfie
//
//  Created by Afzal Hossain on 09.06.21.
//

import UIKit

public class OvalOverlayView: UIView {
    
    let screenBounds = UIScreen.main.bounds
    var ovalOverlay = CGRect.zero
    
    init() {
        super.init(frame: screenBounds)
        backgroundColor = .clear
        ovalOverlay = CGRect(x: (screenBounds.width - 300.0) / 2,y: (screenBounds.height - 400.0) / 2,width: 300.0,height: 400.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        
        
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        
        context.saveGState()
        context.restoreGState()
        
        // draw oval layer
        context.setLineWidth(2)
        context.addEllipse(in: ovalOverlay)
        
        UIColor.green.setStroke()
        context.strokePath()
        UIColor.white.setStroke()
    }
}
