//
//  UIGestureRecognizer+Extension.swift
//  AttributedTextKit
//
//  Created by 蔡志文 on 2020/7/20.
//

import UIKit


extension UIGestureRecognizer {
    
    private struct AssociateKeys {
        static var handlerName = "handlerName"
        static var handlerDelayName = "handlerDelayName"
        static var shouldHandleAction = "shouldHandleAction"
    }
    
    typealias Handler = (UIGestureRecognizer, UIGestureRecognizer.State, CGPoint) -> Void
    
    var handler: Handler? {
        get {
            return (objc_getAssociatedObject(self, &AssociateKeys.handlerName) as! UIGestureRecognizer.Handler)
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.handlerName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var handlerDelay: TimeInterval {
        get {
            return (objc_getAssociatedObject(self, &AssociateKeys.handlerDelayName) as! TimeInterval)
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.handlerDelayName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var shouldHandleAction: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.shouldHandleAction) as! Bool
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.shouldHandleAction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    class func recognizer(with handler: @escaping Handler, delay: TimeInterval = 0) -> UIGestureRecognizer {
        return UIGestureRecognizer(handler, delay: delay)
    }
    
    convenience init(_ handler: @escaping Handler, delay: TimeInterval = 0) {
//        self.init(target: self, action: #selector(handleAction(recognizer:)))
        self.init()
        addTarget(self, action: #selector(handleAction(recognizer:)))
        self.handler = handler
        self.handlerDelay = delay
        
    }
}

extension UIGestureRecognizer {
    @objc func handleAction(recognizer: UIGestureRecognizer) {
        
        guard let handler = recognizer.handler else { return }
        
        let delay = handlerDelay
        let location = self.location(in: view)
        let block = { [self] in
            if !shouldHandleAction { return }
            handler(self, self.state, location)
        }
        shouldHandleAction = true
        
        if delay == 0 {
            block()
            return
        }
        
        let popTime = DispatchTime(uptimeNanoseconds: UInt64(delay) * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: block)
        
    }
}
