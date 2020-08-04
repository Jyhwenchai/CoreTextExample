//
//  RichTextViewController.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/24.
//

import UIKit

class RichTextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        edgesForExtendedLayout = []
        let frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 400)
        let textDrawView = RichTextView(frame: frame)
        let dataComposer = RichTextComposer()
        textDrawView.data = dataComposer.richTextData(with: frame)
        textDrawView.backgroundColor = UIColor.white
        view.addSubview(textDrawView)
    }
    
}
