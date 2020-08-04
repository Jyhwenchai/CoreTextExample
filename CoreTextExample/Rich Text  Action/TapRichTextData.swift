//
//  TapRichTextData.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/27.
//

import UIKit
import CoreText

class TapRichTextData {
    
    enum DrawMode {
        case lines
        case frame
    }
    
    var attachments: [AttachmentData] = []
    
    private var attributedString = NSMutableAttributedString()
    private var font: UIFont = UIFont.systemFont(ofSize: 14)
    
    var ctFrame: CTFrame!
    var drawMode: DrawMode = .frame
    
    // MARK: - Public
    func add(string: String, attributes: [NSAttributedString.Key: Any]) {
        let textItem = Text(value: string)
        let textAtttributeString = NSAttributedString(string: textItem.value, attributes: attributes)
        attachments.append(AttachmentData(data: textItem, type: .text))
        attributedString.append(textAtttributeString)
    }
    
    func add(link: String, handler: ((AttachmentData) -> Void)? = nil) {
        let linkItem = Link(value: link)
        let attachment = AttachmentData(data: linkItem, type: .link, handler: handler)
        attachments.append(attachment)
        attributedString.append(linkAttributeString(with: attachment))
    }
    
    func add(image: UIImage, size: CGSize, handler: ((AttachmentData) -> Void)? = nil) {
        var imageItem = Image()
        imageItem.value = image
        imageItem.ascent = CTFontGetAscent(font)
        imageItem.descent = CTFontGetDescent(font)
        imageItem.size = size
        let attachment = AttachmentData(data: imageItem, type: .image, handler: handler)
        attachments.append(attachment)
        let imageAttributeString = imageAttributedString(with: attachment, size: size)
        attributedString.append(imageAttributeString)
    }
    
    func add(view: UIView, size: CGSize, alignment: View.Alignment = .bottom,  handler: ((AttachmentData) -> Void)? = nil) {
        
        var imageItem = View()
        imageItem.alignment = alignment
        imageItem.value = view
        imageItem.size = size
        imageItem.ascent = CTFontGetAscent(font)
        imageItem.descent = CTFontGetDescent(font)
        let attachemnt = AttachmentData(data: imageItem, type: .view, handler: handler)
        attachments.append(attachemnt)
        let imageAttributeString = viewAttributeString(with: attachemnt, size: size)
        attributedString.append(imageAttributeString)
        
    }
    
    
    func composeDataToDraw(with bounds: CGRect) {
        ctFrame = composeCTFrame(with: attributedString, frame: bounds)
        calculateContentPosition(with: bounds)
    }
    
    func composeCTFrame(with attributeString: NSAttributedString, frame: CGRect) -> CTFrame {
        let path = CGPath(rect: CGRect(origin: .zero, size: frame.size), transform: nil)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributeString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributeString.length), path, nil)
        
        return frame
    }
    
    func calculateContentPosition(with bounds: CGRect) {
        
        let lines = CTFrameGetLines(ctFrame) as! [CTLine]
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lines.count), &lineOrigins)
        
        for (index, line) in lines.enumerated() {
            
            let runs = CTLineGetGlyphRuns(line) as! [CTRun]
            for run in runs {
                let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key: Any]
                if attributes.isEmpty {
                    continue
                }
                
                if let extraInfo = attributes[NSAttributedString.Key.extraInfo] as? RichTextDataExtraInfo {
                    let attachmentType = extraInfo[RichTextDataExtraKey.richTextType] as! AttachmentType
                    let attachmentData = extraInfo[RichTextDataExtraKey.richTextData] as! AttachmentData
                    
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    
                    let width: CGFloat = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
                    let height = ascent + descent
                    
                    let xOffset = lineOrigins[index].x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    let yOffset = bounds.height - lineOrigins[index].y - ascent
                    
                    let clickableFrame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        
                    
//                    if attachmentType == .link,
//                       let data = attachmentData.data as? Link,
//                       containsAttachemntData(with: Link.self, attachmentData: attachmentData) {
//                        attachmentData.add(frame: clickableFrame)
//                    }
//
//                    if attachmentType == .image,
//                       let data = attachmentData as? AttachmentData<Image>,
//                         containsAttachemntData(with: Image.self, attachmentData: data) {
//                        data.add(frame: clickableFrame)
//                    }
//
//                    if attachmentType == .view,
//                       let data = attachmentData as? AttachmentData<View>,
//                         containsAttachemntData(with: View.self, attachmentData: data) {
//                        data.add(frame: clickableFrame)
//                    }
                    
                    if attachmentType != .view {
                        attachmentData.add(frame: clickableFrame)
                    }
                    
                }
                
                guard let runDelegate = attributes[kCTRunDelegateAttributeName as NSAttributedString.Key] else { continue }
                let delegate = runDelegate as! CTRunDelegate
                
                var ascent: CGFloat = 0
                var desent: CGFloat = 0
                
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, nil))
                let height = ascent + desent
                // 获取CTRun的起始位置
                let xOffset = lineOrigins[index].x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                var yOffset = lineOrigins[index].y
                
                let pointer = CTRunDelegateGetRefCon(delegate)
              
                let attachmentData = pointer.load(as: AttachmentData.self)

                if var view = attachmentData.data as? Image {
                    yOffset = yOffset - desent
                    view.frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
                    attachmentData.data = view
                }
                
                if var view = attachmentData.data as? View {
                    yOffset = bounds.size.height - lineOrigins[index].y - ascent
                    view.frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
                    attachmentData.data = view
                }
            }
        }
        
    }
    
    func containsAttachemntData<T: Uniqueable>(with type: T.Type,  attachmentData: AttachmentData) -> Bool {
        return attachments.contains {
            return ($0.data as! T).id == (attachmentData.data as! T).id
        }
    }
}

extension TapRichTextData {
    // MARK: - Private
    func linkAttributeString(with link: AttachmentData) -> NSAttributedString {
        let data = link.data as! Link
        
        let attributeString = NSMutableAttributedString(string: data.value, attributes: linkTextAttributes)
        let extraInfo = RichTextDataExtraInfo()
        extraInfo.addExtraInfo(with: .richTextType, value: AttachmentType.link)
        extraInfo.addExtraInfo(with: .richTextData, value: link)
        
        CFAttributedStringSetAttribute(attributeString, CFRangeMake(0, data.value.count), NSAttributedString.Key.extraInfo as CFString, extraInfo)
        
        return attributeString
    }
    
    func imageAttributedString(with image: AttachmentData, size: CGSize) -> NSAttributedString {
        
        // 创建CTRunDelegateCallbacks
        var callBack = getCallBack(with: AttachmentData.self)
        
        let pointer = UnsafeMutablePointer<AttachmentData>.allocate(capacity: 1)
        pointer.initialize(to: image)
        let runDelegate = CTRunDelegateCreate(&callBack, pointer)
        
        // 3. 设置占位使用的图片属性字符串
        let objectReplacementChar = Unicode.Scalar(0xFFFC)!
        let imagePlaceholderAttributeString = NSMutableAttributedString(string: String(objectReplacementChar), attributes: defaultTextAttributes)
        
        // 4. 设置RunDelegate代理
        CFAttributedStringSetAttribute(imagePlaceholderAttributeString, CFRange(location: 0, length: 1), kCTRunDelegateAttributeName, runDelegate)
        
        
        // 设置附加数据，设置点击效果
        let extraInfo = RichTextDataExtraInfo()
        extraInfo.addExtraInfo(with: .richTextType, value: AttachmentType.image)
        extraInfo.addExtraInfo(with: .richTextData, value: image)

        CFAttributedStringSetAttribute(imagePlaceholderAttributeString, CFRangeMake(0, 1), NSAttributedString.Key.extraInfo as CFString, extraInfo)
        
        return imagePlaceholderAttributeString
        
    }
    
    func viewAttributeString(with view: AttachmentData, size: CGSize) -> NSAttributedString {
        
        // 创建CTRunDelegateCallbacks
        var callBack = getCallBack(with: AttachmentData.self)
        
        let pointer = UnsafeMutablePointer<AttachmentData>.allocate(capacity: 1)
        pointer.initialize(to: view)
        let runDelegate = CTRunDelegateCreate(&callBack, pointer)
        
        // 3. 设置占位使用的图片属性字符串
        let objectReplacementChar = Unicode.Scalar(0xFFFC)!
        let imagePlaceholderAttributeString = NSMutableAttributedString(string: String(objectReplacementChar), attributes: defaultTextAttributes)
        
        // 4. 设置RunDelegate代理
        CFAttributedStringSetAttribute(imagePlaceholderAttributeString, CFRange(location: 0, length: 1), kCTRunDelegateAttributeName, runDelegate)
        
        
        // 设置附加数据，设置点击效果
        let extraInfo = RichTextDataExtraInfo()
        extraInfo.addExtraInfo(with: .richTextType, value: AttachmentType.view)
        extraInfo.addExtraInfo(with: .richTextData, value: view)

        
        CFAttributedStringSetAttribute(imagePlaceholderAttributeString, CFRangeMake(0, 1), NSAttributedString.Key.extraInfo as CFString, extraInfo)
        
        return imagePlaceholderAttributeString
        
    }
    
    func getCallBack<T>(with type: T.Type) -> CTRunDelegateCallbacks {
        
        let callBack = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { pointer in
            let p = pointer.assumingMemoryBound(to: AttachmentData.self)
            p.deinitialize(count: 1)    // 重置内存为未初始化状态
            p.deallocate()              // 释放内存
        }, getAscent: {  pointer in
            var ascent: CGFloat = 0
            let attachemnt = pointer.assumingMemoryBound(to: AttachmentData.self).pointee
            if attachemnt.type == .image {
                let data = attachemnt.data as! Image
                
                switch data.alignment {
                case .top: ascent = data.ascent
                case .bottom: ascent = data.size.height - data.descent
                case .center: ascent = data.ascent - ((data.descent + data.ascent) - data.size.height) / 2
                }
                
            } else if attachemnt.type == .view {
                let data = attachemnt.data as! View
                switch data.alignment {
                case .top: ascent = data.ascent
                case .bottom: ascent = data.size.height - data.descent
                case .center: ascent = data.ascent - ((data.descent + data.ascent) - data.size.height) / 2
                }
            }
    
            return ascent
                
        }, getDescent: { pointer in

            var descent: CGFloat = 0
            let attachemnt = pointer.assumingMemoryBound(to: AttachmentData.self).pointee
            if attachemnt.type == .image {
                let data = attachemnt.data as! Image
                switch data.alignment {
                case .top: descent = data.size.height - data.ascent
                case .bottom: descent = data.descent
                case .center: descent = data.size.height - data.ascent + ((data.descent + data.ascent) - data.size.height) / 2
                }
            } else {
                let data = attachemnt.data as! View
                switch data.alignment {
                case .top: descent = data.size.height - data.ascent
                case .bottom: descent = data.descent
                case .center: descent = data.size.height - data.ascent + ((data.descent + data.ascent) - data.size.height) / 2
                }
            }

            return descent
        }, getWidth: { pointer in

            let pointee = pointer.assumingMemoryBound(to: AttachmentData.self).pointee
            if pointee.type == .image {
                return (pointee.data as! Image).size.width
            } else if pointee.type == .view {
                return (pointee.data as! View).size.width
            }
            return 0
        })

        return callBack
    }
    
    func getImageAscent(with attachemnt: AttachmentData) -> CGFloat {
        let data = attachemnt.data as! Image
        
        switch data.alignment {
        case .top: return data.ascent
        case .bottom: return data.size.height - data.descent
        case .center: return data.ascent - ((data.descent + data.ascent) - data.size.height) / 2
        }
    }
    
    func getViewAscent(with attachemnt: AttachmentData) -> CGFloat {
        let data = attachemnt.data as! View
        switch data.alignment {
        case .top: return data.ascent
        case .bottom: return data.size.height - data.descent
        case .center: return data.ascent - ((data.descent + data.ascent) - data.size.height) / 2
        }
    }
    
    func getImageDescent(with attachemnt: AttachmentData) -> CGFloat {
        let data = attachemnt.data as! Image
        switch data.alignment {
        case .top: return data.size.height - data.ascent
        case .bottom: return data.descent
        case .center: return data.size.height - data.ascent + ((data.descent + data.ascent) - data.size.height) / 2
        }
    }
    
    func getViewDescent(with attachemnt: AttachmentData) -> CGFloat {
        let data = attachemnt.data as! View
        switch data.alignment {
        case .top: return data.size.height - data.ascent
        case .bottom: return data.descent
        case .center: return data.size.height - data.ascent + ((data.descent + data.ascent) - data.size.height) / 2
        }
    }
    
}

// MARK: - Config
extension TapRichTextData {
    
    var defaultTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 18),
         .foregroundColor: UIColor.cyan,
        ]
    }
    
    var boldHighlightedTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.boldSystemFont(ofSize: 24),
         .foregroundColor: UIColor.red,
        ]
    }
    
    var linkTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 18),
         .foregroundColor: UIColor.blue,
         .underlineStyle: 1,
         .underlineColor: UIColor.blue
        ]
    }
}

extension TapRichTextData {
    func item(at point: CGPoint) -> AttachmentData? {
        for item in attachments where item.contains(point: point) {
            return item
        }

        return nil
    }
}
