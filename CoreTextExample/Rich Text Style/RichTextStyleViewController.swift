//
//  RichTextStyleViewController.swift
//  CoreTextExample
//
//  Created by 蔡志文 on 2020/7/29.
//

import UIKit

class RichTextStyleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        let block1: () -> () = { [self] in
            let frame = CGRect(x: 0, y: 88, width: view.bounds.width, height: 100)
            let drawView = StyleDrawView(frame: frame)
            drawView.backgroundColor = .white
            drawView.text = "color:red font:16\n这是一个最好的时代，也是一个最坏的时代；这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日；我们面前应有尽有，我们面前一无所有；我们都将直上天堂，我们都将直下地狱。"
            drawView.textColor = .red
            drawView.font = UIFont.systemFont(ofSize: 16)
            
            view.addSubview(drawView)
        }
        
        block1()
        
        let block2: () -> () = { [self] in
            let frame = CGRect(x: 0, y: 200, width: view.bounds.width, height: 100)
            let drawView = StyleDrawView(frame: frame)
            drawView.backgroundColor = .white
            drawView.text = "color:gray font:16 align:center\n这是一个最好的时代，也是一个最坏的时代；这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日；我们面前应有尽有，我们面前一无所有；我们都将直上天堂，我们都将直下地狱。"
            drawView.textColor = .red
            drawView.font = UIFont.systemFont(ofSize: 16)
            drawView.textAlignment = .center
            view.addSubview(drawView)
        }
        
        block2()
        
        let block3: () -> () = { [self] in
            let frame = CGRect(x: 0, y: 320, width: view.bounds.width, height: 100)
            let drawView = StyleDrawView(frame: frame)
            drawView.backgroundColor = .white
            drawView.text = "color:gray font:14 align:center lineSpacing:10\n这是一个最好的时代，也是一个最坏的时代；这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日；我们面前应有尽有，我们面前一无所有；我们都将直上天堂，我们都将直下地狱。"
            drawView.textColor = .darkGray
            drawView.font = UIFont.systemFont(ofSize: 14)
            drawView.textAlignment = .center
            drawView.lineSpacing = 10
            view.addSubview(drawView)
        }
        
        block3()
        
        let block4: () -> () = { [self] in
            let frame = CGRect(x: 0, y: 450, width: view.bounds.width, height: 100)
            let drawView = StyleDrawView(frame: frame)
            drawView.backgroundColor = .white
            drawView.text = "这是一个最好的时代，也是一个最坏的时代；这是明智的时代，这是愚昧的时代；这是信任的纪元，这是怀疑的纪元；这是光明的季节，这是黑暗的季节；这是希望的春日，这是失望的冬日；我们面前应有尽有，我们面前一无所有；我们都将直上天堂，我们都将直下地狱。"
            drawView.textColor = .cyan
            drawView.font = UIFont.systemFont(ofSize: 20)
            drawView.textAlignment = .center
            drawView.lineSpacing = 10
            drawView.shadowColor = UIColor.black
            drawView.shadowOffset = CGSize(width: 2, height: 2)
            drawView.shadowAlpha = 1.0
            view.addSubview(drawView)
        }
        
        block4()
    }
    
}

