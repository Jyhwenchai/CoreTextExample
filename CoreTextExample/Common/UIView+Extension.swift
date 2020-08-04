//
//  UIView+Extension.swift
//  AttributedTextKit
//
//  Created by 蔡志文 on 2020/7/20.
//

import UIKit

extension UIView {
    func whenTouches(of numbers: Int, taps: Int, handler: @escaping () -> Void) {
        let gesture = UITapGestureRecognizer { (sender, state, location) in
            if state == .recognized {
               handler()
            }
        }
        
        gesture.numberOfTouchesRequired = numbers
        gesture.numberOfTapsRequired = taps
        
        guard let gestures = gestureRecognizers else {
            addGestureRecognizer(gesture)
            return
        }
        
        for gesture in gestures where type(of: gesture) == UITapGestureRecognizer.self {
            let tapGesture = gesture as! UITapGestureRecognizer
            let rightTouches = tapGesture.numberOfTouchesRequired == numbers
            let rightTaps = tapGesture.numberOfTapsRequired == taps
            if rightTouches && rightTaps {
                gesture.require(toFail: tapGesture)
            }
        }
        addGestureRecognizer(gesture)
    }
    
    func when(tapped: @escaping () -> Void) {
        whenTouches(of: 1, taps: 1, handler: tapped)
    }
    
    func whenDouble(tapped: @escaping () -> Void) {
        whenTouches(of: 2, taps: 1, handler: tapped)
    }
    
    func eachSubView(_ block: (UIView) -> Void) {
        for subView in subviews {
            block(subView)
        }
    }
}


