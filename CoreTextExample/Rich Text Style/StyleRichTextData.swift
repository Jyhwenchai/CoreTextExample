//
//  StyleRichTextData.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/29.
//

import UIKit
import CoreText

class StyleRichTextData {
    
    enum DrawMode {
        case lines
        case frame
    }
    
    var attachments: [AttachmentData] = []
    
    private var attributedString = NSMutableAttributedString()
    
    var attributedStringToDraw: NSAttributedString {
        setStyle(to: attributedString)
        return attributedString
    }
    
    var ctFrame: CTFrame!
    var linesToDraw: [Line] = []
    var drawMode: DrawMode = .frame
    
    
    var numbersOfLines: Int = 0
    var truncationToken: NSAttributedString? //<截断的标识字符串，默认是"..."
    var truncationActionHandler: ((AttachmentData) -> Void)? = nil //<截断的标识字符串点击事件
    
    var text: String = "" {
        didSet {
            attributedString.append(NSAttributedString(string: text))
            attributedString.set(font: font)
            attributedString.set(textColor: textColor)
        }
    }
    
    var textColor: UIColor = .black {
        didSet {
            attributedString.set(textColor: textColor)
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            attributedString.set(font: font)
            updateAttachmennnts()
        }
    }
    
    var shadowColor: UIColor = .black
    var shadowOffset: CGSize = .zero
    var shadowAlpha: CGFloat = 0.75
    var lineBreakMode: CTLineBreakMode = .byTruncatingTail
    var lineSpacing: CGFloat = 5    // 行间距
    var paragraphSpacing: CGFloat = 0  // 段间距
    var textAlignment: CTTextAlignment = .left  // 文字排版方式
    private var truncations: [AttachmentData] = []
    
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
        ctFrame = composeCTFrame(with: attributedStringToDraw, frame: bounds)
        calculateContentPosition(with: bounds)
        calculateTruncatedLines(with: bounds)
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
    
    func calculateTruncatedLines(with bounds: CGRect) {
        // 清楚旧数据
        truncations.removeAll()
        
        // 获取最终需要绘制的文本行数
        let numberOfLinesToDraw = self.numberOfLinesToDraw(with: ctFrame!)
        if numberOfLinesToDraw <= 0 {
            drawMode = .frame
        } else {
            drawMode = .lines
            let lines = CTFrameGetLines(ctFrame) as! [CTLine]
            var lineOrigins = [CGPoint](repeating: .zero, count: numberOfLinesToDraw)
            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfLinesToDraw), &lineOrigins)
            
            for (index, line) in lines.enumerated() where index < numbersOfLines {
                let range = CTLineGetStringRange(line)
                
                // 判断最后一行是否需要显示【截断标识字符串(...)】
                if index == numberOfLinesToDraw - 1
                    && range.location + range.length < attributedStringToDraw.length {
                    // 创建【截断标识字符串(...)】
                    var tokenString: NSAttributedString!
                    if let truncationToken = truncationToken {
                        tokenString = truncationToken
                    } else {
                        let truncationAttributePosition = range.location + range.length - 1
                        let attributes = attributedStringToDraw.attributes(at: truncationAttributePosition, effectiveRange: nil)
                        // 只要用到字体大小和颜色的属性，这里如果使用kCTParagraphStyleAttributeName属性在使用boundingRectWithSize方法计算大小的步骤会崩溃
                        
                        let tokenAttributes = [
                            NSAttributedString.Key.foregroundColor: attributes[.foregroundColor] ?? UIColor.black,
                            .font: attributes[.font] ?? UIFont.systemFont(ofSize: 14)
                        ]
                        
                        // unicode \u2026 表示 ...
                        tokenString = NSAttributedString(string: "\u{2026}", attributes: tokenAttributes)
                        
                    }
                    
                    // 计算【截断标识字符串(...)】的长度
                    let tokenSize = tokenString .boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                    let tokenWith = tokenSize.width
                    let truncationTokenLine = CTLineCreateWithAttributedString(tokenString)
                    
                    
                    // 根据【截断标识字符串(...)】的长度，计算【需要截断字符串】的最后一个字符的位置，把该位置之后的字符从【需要截断字符串】中移除，留出【截断标识字符串(...)】的位置
                    
                    let truncationEndIndex = CTLineGetStringIndexForPosition(line, CGPoint(x: bounds.size.width - tokenWith, y: 0))
                    let length = range.location + range.length - truncationEndIndex
                    
                    // 把【截断标识字符串(...)】添加到【需要截断字符串】后面
                    let truncationString = attributedStringToDraw.attributedSubstring(from: NSRange(location: range.location, length: range.length)).mutableCopy() as! NSMutableAttributedString
                    if length < truncationString.length {
                        truncationString.deleteCharacters(in: NSRange(location: truncationString.length - length, length: length))
                        truncationString.append(tokenString)
                    }
                    
                    // 使用`CTLineCreateTruncatedLine`方法创建含有【截断标识字符串(...)】的`CTLine`对象
                    let truncationLine = CTLineCreateWithAttributedString(truncationString)
                    let truncationType = CTLineTruncationType.end
                    let lastLine = CTLineCreateTruncatedLine(truncationLine, Double(bounds.size.width), truncationType, truncationTokenLine)
                    
                    // 添加truncation的位置信息
                    let runs = CTLineGetGlyphRuns(line) as! [CTRun]
                    if let handler = truncationActionHandler, runs.count > 0 {
                        let run = runs.last!
                        var ascent: CGFloat = 0
                        var desent: CGFloat = 0
                        
                        // 可以直接从metaData获取到图片的宽度和高度信息
                        let width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, nil))
                        let height = ascent + desent
                        
                        let truncationItem = AttachmentData(data: Text(value: ""), type: .text)
                        let truncationFrame = CGRect(x: width - tokenWith,
                                                     y: bounds.size.height - lineOrigins[index].y - height,
                                                     width: tokenSize.width, height: tokenSize.height)
                        
                        truncationItem.add(frame: truncationFrame)
                        truncationItem.clickableHandler = handler
                        truncations.append(truncationItem)
                    }
                    
                    let line = Line(position: CGPoint(x: lineOrigins[index].x, y: lineOrigins[index].y), ctLine: lastLine!)
                    linesToDraw.append(line)
                } else {
                    let line = Line(position: CGPoint(x: lineOrigins[index].x, y: lineOrigins[index].y), ctLine: line)
                    linesToDraw.append(line)
                }
            }
            
        }
    }
    
    func containsAttachemntData<T: Uniqueable>(with type: T.Type,  attachmentData: AttachmentData) -> Bool {
        return attachments.contains {
            return ($0.data as! T).id == (attachmentData.data as! T).id
        }
    }
    
    func numberOfLinesToDraw(with ctFrame: CTFrame) -> CFIndex {
        if numbersOfLines <= 0 {
            return numbersOfLines
        }
        return min(CFArrayGetCount(CTFrameGetLines(ctFrame)), numbersOfLines)
    }
}

extension StyleRichTextData {
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
extension StyleRichTextData {
    
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

extension StyleRichTextData {
    func item(at point: CGPoint) -> AttachmentData? {
        for item in attachments where item.contains(point: point) {
            return item
        }
        
        for item in truncations where item.contains(point: point) {
            return item
        }

        return nil
    }
}

extension StyleRichTextData {
    func updateAttachmennnts() {
        for index in 0..<attachments.count {
            update(attachment: attachments[index], with: font)
        }
    }
    
    func update(attachment: AttachmentData, with font: UIFont) {
   
//        attachment.ascent = CTFontGetAscent(font)
//        attachment.descent = CTFontGetDescent(font)
    }
    
    func setStyle(to attributeString: NSMutableAttributedString) {
        var settings = [CTParagraphStyleSetting]()
        let pointer = UnsafeMutablePointer<CTTextAlignment>.allocate(capacity: 1)
        pointer.initialize(to: textAlignment)

        let maxLinePointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        maxLinePointer.initialize(to: lineSpacing)

        let minLinePointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        minLinePointer.initialize(to: lineSpacing)

        let paragraphPointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        paragraphPointer.initialize(to: paragraphSpacing)

        settings.append(CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: pointer))
        settings.append(CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: maxLinePointer))
        settings.append(CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: minLinePointer))
        settings.append(CTParagraphStyleSetting(spec: .paragraphSpacing, valueSize: MemoryLayout<CGFloat>.size, value: paragraphPointer))

        let paragraphStyle = CTParagraphStyleCreate(settings, settings.count)
        attributeString.addAttribute(kCTParagraphStyleAttributeName as NSAttributedString.Key, value: paragraphStyle, range: NSMakeRange(0, attributeString.length))
        
//        let style = NSMutableParagraphStyle()
//        style.alignment = .left
//        style.lineSpacing = lineSpacing
//        style.paragraphSpacing = paragraphSpacing
//        attributeString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributeString.length))
    }
}
