import UIKit

public extension NSMutableAttributedString {
    func textColor(_ color: UIColor) -> NSMutableAttributedString {
        addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: length))
        return self
    }
    
    func font(_ font: UIFont) -> NSMutableAttributedString {
        addAttribute(.font, value: font, range: NSRange(location: 0, length: length))
        return self
    }
}
