import UIKit
import CoreText

class RichTextData {
    public var frame: CTFrame
    public var images: [ImageData] = []
    public var attributedString: NSAttributedString
    
    init(frame: CTFrame, images: [ImageData], attributedString: NSAttributedString) {
        self.frame = frame
        self.images = images
        self.attributedString = attributedString
    }
}

