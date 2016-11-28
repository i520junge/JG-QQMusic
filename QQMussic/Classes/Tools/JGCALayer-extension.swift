//
//  JGCALayer-extension.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/27.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit


extension CALayer {
    
    
    /// 停止动画
    func pauseAnim() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    /// 从停止的位置开始 恢复动画
    func resumeAnim() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let currentTime = convertTime(CACurrentMediaTime(), from: nil)
        beginTime = currentTime - pausedTime
    }
}

extension CAAnimation{
    class func rotationAnim()->CAAnimation{
        //1、创建动画
        let rotationAni = CABasicAnimation(keyPath: "transform.rotation.z")
        
        //2、设置动画参数
        rotationAni.fromValue = 0
        rotationAni.toValue = M_PI*2
        rotationAni.repeatCount = MAXFLOAT
        rotationAni.duration = 25   //30秒执行完这个动画
        
        return rotationAni
    }
}

