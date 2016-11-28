//
//  JGLrcModel.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/28.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit

class JGLrcLineModel: NSObject {
    var lrcString : String = ""           //一行的歌词
    var lrcTime : TimeInterval = 0    //那行歌词播放的时间
    
    /// 提供构造函数，将“[00:26.51]朋友 你試過將我營救” 中时间字符转为时间赋值给lrcTime，文字赋值给lrcString
    init(_ lrcLineString:String) {
//        1、分割出歌词
        let lrcLineStrs = lrcLineString.components(separatedBy: "]")
        lrcString = lrcLineStrs[1]
        
//        2、分割出时间，并转为秒
        let lrcLineTime = lrcLineStrs[0].components(separatedBy: "[")[1]//00:26.51
        let minute = Double(lrcLineTime.components(separatedBy: ":")[0])//00和26.51
        let second = Double(lrcLineTime.components(separatedBy: ":")[1].components(separatedBy: ".")[0])
        let milliscond = Double(lrcLineTime.components(separatedBy: ".")[1])
        
        lrcTime = minute!*60 + second! + milliscond!*0.01
    }
}
