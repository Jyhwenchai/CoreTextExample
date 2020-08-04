//
//  RichTextView.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/24.
//

import UIKit

class RichTextView: UIView {

    var data: RichTextData?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let data = data else { return }
        
        let context = UIGraphicsGetCurrentContext()
        context?.textMatrix = .identity
        context?.translateBy(x: 0, y: bounds.height)
        context?.scaleBy(x: 1, y: -1)
        
        CTFrameDraw(data.frame, context!)
        
        for i in 0..<data.images.count {
            let item = data.images[i]
            context?.draw(item.image.cgImage!, in: item.frame)
        }
    }
}
