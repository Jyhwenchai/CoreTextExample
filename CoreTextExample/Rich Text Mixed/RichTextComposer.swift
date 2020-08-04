import UIKit
import CoreText


public class RichTextComposer {

    var richTextData: RichTextData!
    
    
    var attributedString: NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        var textAttributedString = NSMutableAttributedString(string: "Hello, World!").font(.systemFont(ofSize: 18)).textColor(.black)
        attributedString.append(textAttributedString)
        
        textAttributedString = NSMutableAttributedString(string: "www.baidu.com").font(.systemFont(ofSize: 18)).textColor(.systemBlue)
        attributedString.append(textAttributedString)
        
        // add spacing
        attributedString.append(createSpacingAttributedString())
        
        // add image
        attributedString.append(imageAttributedString)
        
        // add spacing
        attributedString.append(createSpacingAttributedString())
        
        textAttributedString = NSMutableAttributedString(string: "Core Text is an advanced, low-level technology for laying out text and handling fonts. ").font(.systemFont(ofSize: 18)).textColor(.black)
        attributedString.append(textAttributedString)
        
        return attributedString
    }
    
    var imageAttributedString:  NSAttributedString {
        var callback = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { pointer in
            let p = pointer.assumingMemoryBound(to: [String: CGFloat].self)
            p.deinitialize(count: 1)    // 重置内存为未初始化状态
            p.deallocate()              // 释放内存
        }, getAscent: { pointer in
            return pointer.assign([String: CGFloat].self)["height"]!
        }, getDescent: { pointer in
            return 0;
        }, getWidth: { pointer in
            return pointer.assign([String: CGFloat].self)["width"]!
        })
        
        let metaData: [String: CGFloat] = ["width": 60, "height": 60]
        let metaDataPointer = UnsafeMutablePointer<[String: CGFloat]>
            .allocate(capacity: 1)      // 分配内存空间
        metaDataPointer.initialize(to: metaData)   // 初始化内存的值

        
        /// `run-delegate` 可用于保留一行中的空间或用于完全隐藏一系列文本的字形。
        /// 这里使用放置一张图片
        let runDelegate = CTRunDelegateCreate(&callback, metaDataPointer)
        
    
        // 占位符字符串
        let placeholderChar = Unicode.Scalar(0xFFFC)!
        let attributedString = NSMutableAttributedString(string: String(placeholderChar))
        
        // 设置 RunDelegate 代理
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, 1), kCTRunDelegateAttributeName, runDelegate)
        
        return attributedString
        
    }
    
    func createSpacingAttributedString() -> NSAttributedString {
        var callback = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1,
                                              dealloc: { $0.deallocate() },
                                              getAscent: { _ in return 0 },
                                              getDescent: { _ in return 0 },
                                              getWidth: { _ in return 10
        })
        
        /// `run-delegate` 可用于保留一行中的空间或用于完全隐藏一系列文本的字形。
        /// 这里使用它控制图片两边的间距
        let runDelegate = CTRunDelegateCreate(&callback, nil)
        
        let placeholderChar = Unicode.Scalar(0xFFFC)!
        let attributedString = NSMutableAttributedString(string: String(placeholderChar), attributes: [NSAttributedString.Key.kern: 10])
        
        attributedString.addAttribute(kCTRunDelegateAttributeName as NSAttributedString.Key, value: runDelegate!, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key("spacing"), value: 10, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    func richTextData(with frame: CGRect) -> RichTextData {
        
        if let _ = richTextData {
            return richTextData
        }
        let frame = ctFrame(with: attributedString, frame: frame)
        let image = ImageData(image: UIImage(color: UIColor.systemYellow, size: CGSize(width: 60, height: 60))!, frame: CGRect.zero)
        
        richTextData = RichTextData(frame: frame, images: [image], attributedString: attributedString)
        calculatePosition()
        
        return richTextData
        
    }
    
    func ctFrame(with attributeString: NSAttributedString, frame: CGRect) -> CTFrame {
        let path = CGPath(rect: CGRect(origin: .zero, size: frame.size), transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributeString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributeString.length), path, nil)
        return frame
    }
    
    func calculatePosition() {
        var imageIndex = 0
        if imageIndex >= richTextData.images.count {
            return
        }
        
        // 获取 CTFrame 的行数
        let lines = CTFrameGetLines(richTextData.frame) as! [CTLine]
        
        var lineOrigins: [CGPoint] = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(richTextData.frame, CFRange(location: 0, length: lines.count), &lineOrigins)
        
        for (index, line) in lines.enumerated() {
            let runs = CTLineGetGlyphRuns(line) as! [CTRun]
            for run in runs {
                let attributes = CTRunGetAttributes(run) as! [NSAttributedString.Key: Any]
                
                if attributes.count == 0 {
                    continue
                }
                
                // 检查是否是图片
                guard let _ = attributes[kCTRunDelegateAttributeName as NSAttributedString.Key] else { continue }
                if let _ = attributes[NSAttributedString.Key("spacing")] {
                    continue
                }
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                
                // 获取绘制的 width、ascent、descent、等信息，这部分信息由自己设置（在前面的 imageAttributedString 中进行了配置）
                let width = CTRunGetTypographicBounds(run, CFRange(location: 0, length: 0), &ascent, &descent, nil)
                
                // `CTRunGetStringRange` 获取运行中最初产生字形的字符范围。
                // `CTLineGetOffsetForStringIndex` 确定字符串索引的图形偏移量。
                let xOffset = lineOrigins[index].x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                let yOffset = lineOrigins[index].y
                
                // 更新ImageData对象的位置
                var imageItem = richTextData.images[imageIndex]
                imageItem.frame = CGRect(x: xOffset, y: yOffset, width: CGFloat(width), height: ascent + descent)
                richTextData.images.remove(at: imageIndex)
                richTextData.images.insert(imageItem, at: imageIndex)
                imageIndex += 1
                if imageIndex >= richTextData.images.count {
                    return
                }
                 
            }
        }
    }
}

