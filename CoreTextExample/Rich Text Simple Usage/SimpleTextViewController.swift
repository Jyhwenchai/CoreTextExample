//
//  SimpleTextViewController.swift
//  CoreText
//
//  Created by 蔡志文 on 2020/7/24.
//

import UIKit

class SimpleTextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        edgesForExtendedLayout = []
        // Do any additional setup after loading the view.
        let singleLineTextView = SingleLineTextView(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: 50))
        singleLineTextView.backgroundColor = UIColor.white
        view.addSubview(singleLineTextView)
        
        let multipleLineTextView = MultipleLineTextView(frame: CGRect(x: 0, y: 120, width: view.bounds.width, height: 100))
        multipleLineTextView.backgroundColor = UIColor.white
        view.addSubview(multipleLineTextView)
    }

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        print(view.safeAreaInsets)
    }
}
