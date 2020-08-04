//
//  RichTextTruncationViewController.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/29.
//

import UIKit

class RichTextTruncationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        var frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 100)
        var drawView = StyleDrawView(frame: frame)
        drawView.backgroundColor = UIColor.white
        drawView.numberOfLines = 3

        drawView.add(string: "这是一个最好的时代，也是一个最坏的时代；这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日；我们面前应有尽有，我们面前一无所有；我们都将直上天堂，我们都将直下地狱。", attributes: defaultTextAttributes) { obj in

        }
        view.addSubview(drawView)
        
        let truncationToken = NSAttributedString(string: "查看更多", attributes: truncationTextAttributes)
        frame = CGRect(x: 0, y: 240, width: view.bounds.width, height: 100)
        drawView = StyleDrawView(frame: frame)
        drawView.backgroundColor = .white
        drawView.numberOfLines = 2
        drawView.truncationToken = truncationToken
        drawView.add(string: "这是一个最好的时代，也是一个最坏的时代；这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日；我们面前应有尽有，我们面前一无所有；我们都将直上天堂，我们都将直下地狱。", attributes: defaultTextAttributes) { obj in

        }

        drawView.truncationActionHandler = { [weak drawView] obj in
            print("点击查看更多")
            drawView?.numberOfLines = 0
        }

        view.addSubview(drawView)
    }

}

// MARK: - Config
extension RichTextTruncationViewController {
    var defaultTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 18),
         .foregroundColor: UIColor.black
        ]
    }
    
    var truncationTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 18),
         .foregroundColor: UIColor.blue
        ]
    }

}
