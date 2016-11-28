//
//  JGLrcLabel.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/28.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit

class JGLrcLabel: UILabel {
    
    /// 渐变值：决定画到什么进度
    var shading:Double = 0{
        didSet{
            setNeedsDisplay()   //刷新，让draw方法再次调用
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor.green.set() //颜色
        let drawRect = CGRect(x: 0, y: 0, width: rect.width*CGFloat(shading), height: rect.height)
        // /* R = S*Da */
        // S : 填充的透明度  --> 1.0
        // Da : 原有的透明度  --> 0.0/1.0
        // /* R = S*(1 - Da) */
        UIRectFillUsingBlendMode(drawRect, .sourceIn)
    }
}
