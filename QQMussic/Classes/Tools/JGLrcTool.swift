//
//  JGLrcTool.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/28.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit

class JGLrcTool: NSObject {

}

extension JGLrcTool{
    
    /// 根据歌曲名字，找到对应歌词，并解析成一行一行拥有歌词和播放时间的模型数组
    ///
    /// - Parameter lrcName: 歌曲名字
    /// - Returns: 过滤掉了没用的歌词模型数组
    class func parseLrc(_ lrcName:String)->([JGLrcLineModel]?){//这个数组用可选型，因为不知道能不能获取到
//        1、获取路径
        guard let path = Bundle.main.path(forResource: lrcName, ofType: nil) else{return nil}
        
//        2、读取路径中的内容
        guard let totalLrcText = try? String(contentsOfFile: path) else{return nil}
        
//        3、将内容分割成一句一句，并保存到模型中
        let lrcLineStrings = totalLrcText.components(separatedBy: "\n")
        var lrcLineModelArr:[JGLrcLineModel] = [JGLrcLineModel]()//定义模型数组接收
        
        //遍历每一行歌词，转为模型
        for lrcLineStr in lrcLineStrings{
            //①过滤掉不要的行数：[ti:]、[ar:]、[al:]、没有时间和歌词的
            if lrcLineStr.contains("ti:")||lrcLineStr.contains("ar:")||lrcLineStr.contains("al:") || !lrcLineStr.contains("["){
                continue
            }
            //②取出歌词
            let lrcLineModel = JGLrcLineModel(lrcLineStr)
            lrcLineModelArr.append(lrcLineModel)
        }
        return lrcLineModelArr
    }
}


// 用于画歌词在锁屏上
extension JGLrcTool{
    class func drawLrcLine(_ text:String,image:UIImage,fontSize:CGFloat,textColor:UIColor,numbleLine:Int){
        let nextRect = CGRect(x: 0, y: image.size.height - CGFloat(numbleLine)*textH, width: image.size.width, height: textH)
        let style = NSMutableParagraphStyle()
        style.alignment = .center   //歌词居中
        let nextAttrs = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont.systemFont(ofSize: fontSize), NSParagraphStyleAttributeName : style]    //颜色字体
        (text as NSString).draw(in: nextRect, withAttributes: nextAttrs)
    }
}
