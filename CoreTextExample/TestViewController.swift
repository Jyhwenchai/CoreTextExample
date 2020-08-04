//
//  TestViewController.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/30.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let label = UILabel(frame: CGRect(x: 10, y: 100, width: view.bounds.width - 20, height: 0))
        label.text = "上课的弗兰克大两地分居；爱思大开发静安寺离开的飞机；啊；莱克斯顿就发了啥的看法看电视放辣椒地方喀什东路咖啡机爱上的看法；的咖啡机；爱上的看法克劳福德静安里发生的减肥啦开始的加法开始两地分居数控刀具弗兰克斯"
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.sizeToFit()
        view.addSubview(label)
        
        print(label.attributedText)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}
