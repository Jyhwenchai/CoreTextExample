//
//  AttachmentData.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/27.
//

import UIKit

enum AttachmentType {
    case text
    case link
    case image
    case view
}

protocol Attachmentable {
    func add(frame: CGRect)
    func contains(point: CGPoint) -> Bool
}

protocol Uniqueable: Identifiable, Equatable {}


class AttachmentData {
    
    var data: Any
    var type: AttachmentType
    
    var layoutFrames: [CGRect] = []
    
    typealias Handler = (AttachmentData) -> Void
    var clickableHandler: Handler?
    
    init(data: Any, type: AttachmentType, handler: Handler? = nil) {
        self.data = data
        self.type = type
        self.clickableHandler = handler
    }
    
}


extension AttachmentData: Attachmentable {
    
    func add(frame: CGRect) {
        layoutFrames.append(frame)
    }
    
    func contains(point: CGPoint) -> Bool {
        for frame in layoutFrames where frame.contains(point) {
            return true
        }
        return false
    }
}


struct Text: Uniqueable {
    var id = UUID()
    var value: String
    
    static func == (lhs: Text, rhs: Text) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Link: Uniqueable {
    var id = UUID()
    var value: String
    static func == (lhs: Link, rhs: Link) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Image: Uniqueable {
    var id = UUID()
    enum Alignment {
        case bottom
        case center
        case top
    }
    
    var frame: CGRect = .zero
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var size: CGSize = .zero
    var alignment: Alignment = .bottom
    var value: UIImage?
    
    static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.id == rhs.id
    }
}

struct View: Uniqueable {
    var id = UUID()
    enum Alignment {
        case bottom
        case center
        case top
    }
    
    var frame: CGRect = .zero
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var size: CGSize = .zero
    var alignment: Alignment = .bottom
    var value: UIView?
    
    static func == (lhs: View, rhs: View) -> Bool {
        return lhs.id == rhs.id
    }
}
