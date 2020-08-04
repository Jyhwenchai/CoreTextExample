//
//  RichTextDataExtraKey.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/28.
//

import Foundation

struct RichTextDataExtraKey: Hashable {
    var value: String
    init(_ rawValue: String) {
        value = rawValue
    }
   
    static let richTextType = RichTextDataExtraKey("RichTextType")
    static let richTextData = RichTextDataExtraKey("RichTextData")
}


class RichTextDataExtraInfo {
    
    private var extraInfo: [RichTextDataExtraKey: Any] = [:]
    
    func addExtraInfo(with key: RichTextDataExtraKey, value: Any) {
        extraInfo[key] = value
    }
    
    subscript(_ key: RichTextDataExtraKey) -> Any? {
        extraInfo[key]
    }
    
}

extension NSAttributedString.Key {
    static let extraInfo = NSAttributedString.Key("extraInfo")
}
