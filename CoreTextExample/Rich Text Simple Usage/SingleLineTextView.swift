//
//  SingleLineTextView.swift
//  CoreText
//
//  Created by 蔡志文 on 2020/7/24.
//

import UIKit
import CoreText

class SingleLineTextView: UIView {

    override func draw(_ rect: CGRect) {
        // 获取绘图上下文
        let context = UIGraphicsGetCurrentContext()
        context?.textMatrix = .identity
        
        // 坐标翻转
        context?.translateBy(x: 0, y: bounds.height)
        context?.scaleBy(x: 1, y: -1)
        
        let attriubtes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.red
        ]
        
        let string = "Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine."
        let attrString = NSMutableAttributedString(string: string, attributes: attriubtes)
        
        let line = CTLineCreateWithAttributedString(attrString)
        context?.textPosition = CGPoint(x: 10, y: bounds.height - 50)
        
        CTLineDraw(line, context!)
    }

}
