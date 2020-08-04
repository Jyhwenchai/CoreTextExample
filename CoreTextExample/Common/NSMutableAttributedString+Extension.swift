//
//  NSMutableAttributedString+Extension.swift
//  AttributedTextKit
//
//  Created by 蔡志文 on 2020/7/17.
//

import UIKit

extension NSMutableAttributedString {
    
    func set(textColor: UIColor) {
        set(textColor: textColor, with: NSMakeRange(0, self.length))
    }
    
    func set(textColor: UIColor, with range: NSRange) {
        removeAttribute(.foregroundColor, range: range)
        addAttribute(.foregroundColor, value: textColor, range: range)
    }
    
    func set(font: UIFont) {
        set(font: font, with: NSMakeRange(0, self.length))
    }
    
    func set(font: UIFont, with range: NSRange) {
        removeAttribute(.font, range: range)
        addAttribute(.font, value: font, range: range)
    }
}


