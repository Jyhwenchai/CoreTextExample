//
//  DrawView.swift
//  AttributedTextKit
//
//  Created by 蔡志文 on 2020/7/20.
//

import UIKit

class DrawView: UIView {
    
    typealias ClickActionHandler = (AttachmentData) -> Void
    
//    var numberOfLines = 0 {
//        didSet {
//            data.numbersOfLines = numberOfLines
//            setNeedsDisplay()
//        }
//    }
//    var truncationToken: NSAttributedString? {
//        get { data.truncationToken }
//        set { data.truncationToken = newValue }
//    }
//    var truncationActionHandler: ClickActionHandler? {
//        get { data.truncationActionHandler }
//        set { data.truncationActionHandler = newValue }
//    }
//    var text: String {
//        get { data.text }
//        set { data.text = newValue }
//    }
//
//    var textColor: UIColor {
//        get { data.textColor }
//        set { data.textColor = newValue }
//    }
//
//    var font: UIFont {
//        get { data.font }
//        set { data.font = newValue }
//    }
//
//    var shadowColor: UIColor {
//        get { data.shadowColor }
//        set { data.shadowColor = newValue }
//    }
//
//    var shadowOffset: CGSize {
//        get { data.shadowOffset }
//        set { data.shadowOffset = newValue }
//    }
//
//    var shadowAlpha: CGFloat {
//        get { data.shadowAlpha }
//        set { data.shadowAlpha = newValue }
//    }
//    var lineSpacing: CGFloat {
//        get { data.lineSpacing }
//        set { data.lineSpacing = newValue }
//    }
//
//    var paragraphSpacing: CGFloat {
//        get { data.paragraphSpacing }
//        set { data.paragraphSpacing = newValue }
//    }
//
//    var textAlignment: CTTextAlignment {
//        get { data.textAlignment }
//        set { data.textAlignment = newValue }
//    }
    
    private let COVER_TAG = 100023
    
    var data: TapRichTextData = TapRichTextData()
    var clickedItem: AttachmentData?
    
    
    func add(string: String, attributes: [NSAttributedString.Key: Any], handler: ClickActionHandler?) {
        data.add(string: string, attributes: attributes)
    }
    
    func add(link: String, handler: @escaping ClickActionHandler) {
        data.add(link: link, handler: handler)
    }
    
    func add(image: UIImage, size: CGSize, handler: ClickActionHandler?)  {
        data.add(image: image, size: size, handler: handler)
    }
    
    func add(view: UIView, size: CGSize, align: View.Alignment = .bottom, handler: ClickActionHandler?)  {
        data.add(view: view, size: size, alignment: align, handler: handler)
    }
    
    
    // MARK: - Override
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        let drawString = data.attributeStringToDraw
//        let framesetter = CTFramesetterCreateWithAttributedString(drawString)
//        var range = CFRangeMake(0, 0)
//        if numberOfLines > 0  {
//            let path = CGMutablePath()
//            path.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
//            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
//            let lines = CTFrameGetLines(frame) as! [CTLine]
//
//            if lines.count > 0 {
//                let lastVisibleLineIndex = min(numberOfLines, lines.count - 1)
//                let lastVisibleLine = lines[lastVisibleLineIndex]
//
//                let rangeToLayout = CTLineGetStringRange(lastVisibleLine)
//                range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length)
//            }
//        }
//        var fitRange = CFRangeMake(0, 0)
//        let newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, nil, size, &fitRange)
//        return newSize
//    }
//
//
//    override var intrinsicContentSize: CGSize {
//        return sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
//    }
//
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)
        
        
        data.composeDataToDraw(with: bounds)
        drawShadow(in: context)
        drawText(in: context)
        drawAttachments(in: context)
        
    }
    
    func drawText(in context: CGContext) {
//        switch data.drawMode {
//        case .frame:
//            CTFrameDraw(data.ctFrame, context)
//        case .lines:
//            for line in data.linesToDraw {
//                context.textPosition = line.position
//                CTLineDraw(line.ctLine, context)
//            }
//        }
        CTFrameDraw(data.ctFrame, context)
    }
    
    func drawAttachments(in context: CGContext) {
        for attachment in data.attachments {
            switch attachment.type {
            case .image:
                if let image = attachment.data as? Image {
                    context.draw(image.value!.cgImage!, in: image.frame)
                }
            case .view:
                if let view = attachment.data as? View {
                    view.value!.frame = view.frame
                    addSubview(view.value!)
                }
            default: break
            }
        }
    }
    
    func drawShadow(in context: CGContext) {
//        if data.shadowOffset == .zero {
//            return
//        }
//        context.setShadow(offset: data.shadowOffset, blur: data.shadowAlpha, color: data.shadowColor.cgColor)
    }
    
    // MAKR: - Gesture
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = event!.allTouches!.first!
        if touch.view == self {
            let point = touch.location(in: touch.view)
            let clickedItem = data.item(at: point)
            self.clickedItem = clickedItem
            if let item = self.clickedItem {
                addClickableCover(with: item)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let clickedItem = clickedItem else { return }
        if let handler = clickedItem.clickableHandler {
            handler(clickedItem)
        }
        self.clickedItem = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            removeClickableCoverView()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.clickedItem = nil
        touchesEnded(touches, with: event)
    }
    
    
    func addClickableCover(with item: AttachmentData) {
        for frameValue in item.layoutFrames {
            let coverView = UIView(frame: frameValue)
            coverView.tag = COVER_TAG
            coverView.backgroundColor = UIColor(red: 0.3, green: 1, blue: 1, alpha: 0.3)
            coverView.layer.cornerRadius = 3
            addSubview(coverView)
        }
    }
    
    func removeClickableCoverView() {
        for subView in subviews where subView.tag == COVER_TAG {
            subView.removeFromSuperview()
        }
    }
}
