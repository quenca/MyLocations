//
//  HudView.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 24/05/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import Foundation
import UIKit

class HudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        // It calls HudView(), or actually HudView(frame:) which is an init method inherited from UIView
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    // The draw() method is invoked whenever UIKit wants your view to redraw itself.
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        // There is CGRect again, the struct that represents a rectangle. You use it to calculate the position for the HUD. The HUD rectangle should be centered horizontally and vertically on the screen. The size of the screen is given by bounds.size (this is the size of HudView itself, which spans the entire screen).
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        // UIBezierPath is a very handy object for drawing rectangles with rounded corners. You just tell it how large the rectangle is and how round the corners should be. Then you fill the rectangle with an 80% opaque dark gray color.

        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // Draw checkmark
        if let image = UIImage(named: "Checkmark") {
        let imagePoint = CGPoint(
            x: center.x - round(image.size.width / 2),
            y: center.y - round(image.size.height / 2) - boxHeight / 8)
        image.draw(at: imagePoint)
    }
        
        // Draw the text
        // First, you set up a dictionary of attributes for the text that you want to draw
        let attribs = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
            NSAttributedStringKey.foregroundColor: UIColor.white ]
        
        let textSize = text.size(withAttributes: attribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    // MARK:- Public methods
    func show(animated: Bool) {
       if animated {
            // Set up the initial state of the view before the animation starts
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            // Call UIView.animate(withDuration:animations:) to set up an animation
            UIView.animate(withDuration: 0.3, animations: {
                // Set up the state of the view as it should be after the animation completes
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            })
        }
    // Another Way 
   /* if animated {
        UIView.animate(withDuration: 0.3, delay: 0,
            usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
            options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
         } */
    }
    
    // Hide HUD View
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
