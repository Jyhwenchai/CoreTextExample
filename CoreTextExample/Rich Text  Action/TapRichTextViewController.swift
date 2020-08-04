//
//  TapRichTextViewController.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/27.
//

import UIKit

class TapRichTextViewController: UIViewController {

    var textDrawView: DrawView = DrawView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        textDrawView.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 400)
        textDrawView.backgroundColor = UIColor.white
        
        // 添加普通文本
        textDrawView.add(string: "Hello World ", attributes: defaultTextAttributes) { obj in
            
        }
        
        // 添加链接
        textDrawView.add(link: "http://www.baidu.com") { obj in
            print("click baidu")
        }

        // 添加图片
        textDrawView.add(image: UIImage(named: "tata_img_hottopicdefault")!, size: CGSize(width: 30, height: 30)) { obj in
            print("click image")
        }


        // 添加链接
        textDrawView.add(link: "http://www.baidu.com") { obj in
            print("click baidu2")
        }

        // 添加普通文本
        textDrawView.add(string: "这是一个最好的时代，也是一个最坏的时代；", attributes: defaultTextAttributes) { obj in
            print(obj)
        }

        textDrawView.add(link: "这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日； ") { obj in
            print("link 3")
        }

        // 添加自定义的View，默认是底部对齐
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
        customView.backgroundColor = UIColor(red: 1, green: 0.7, blue: 1, alpha: 0.51)
        customView.when {
            print("customView tapped")
        }

        let labelInCustomView = UILabel(frame: customView.bounds)
        labelInCustomView.textAlignment = .center
        labelInCustomView.font = UIFont.systemFont(ofSize: 12)
        labelInCustomView.text = "可点击的自定义的View"
        labelInCustomView.isUserInteractionEnabled = false
        customView.addSubview(labelInCustomView)

        textDrawView.add(view: customView, size: customView.frame.size, handler: nil)

        textDrawView.add(string: " Hello ", attributes: defaultTextAttributes, handler: nil)

        let unClickableCustomView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
        unClickableCustomView.backgroundColor = UIColor(red: 1, green: 0.7, blue: 1, alpha: 0.51)
        let labelInUnClickableCustomView = UILabel(frame: unClickableCustomView.bounds)
        labelInUnClickableCustomView.textAlignment = .center
        labelInUnClickableCustomView.font = UIFont.systemFont(ofSize: 12)
        labelInUnClickableCustomView.text = "居中对其自定义的View"
        unClickableCustomView.addSubview(labelInUnClickableCustomView)
        textDrawView.add(view: unClickableCustomView, size: unClickableCustomView.frame.size, align: .center, handler: nil)

        // 添加普通文本
        textDrawView.add(string: " 我们面前应有尽有，我们面前一无所有； ", attributes: defaultTextAttributes, handler: nil)

        // 添加自定义的按钮，默认是底部对其
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        button.setTitle("我是按钮", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        textDrawView.add(view: button, size: button.frame.size, handler: nil)
        textDrawView.add(string: " ", attributes: defaultTextAttributes, handler: nil)

        // 添加顶部对齐按钮

        button = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
        button.setTitle("顶部对齐按钮", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        textDrawView.add(view: button, size: button.frame.size, handler: nil)

         // 添加普通文本
        textDrawView.add(string: " 我们都将直上天堂，我们都将直下地狱。 ", attributes: defaultTextAttributes, handler: nil)
        view.addSubview(textDrawView)
    }
    
    @objc func buttonAction() {
        print("button Clicked")
    }
}

// MARK: - Config
extension TapRichTextViewController {
    var defaultTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 18),
         .foregroundColor: UIColor.black
        ]
    }
    
    var boldHighlightedTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.boldSystemFont(ofSize: 24),
         .foregroundColor: UIColor.red
        ]
    }
    
    var linkTextAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 13),
         .foregroundColor: UIColor.blue,
         .underlineStyle: 1,
         .underlineColor: UIColor.blue
        ]
    }

}
