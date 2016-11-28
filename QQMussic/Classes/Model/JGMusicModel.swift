//
//  JGMusicModel.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/27.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit

class JGMusicModel: NSObject {
    /// 歌曲名称
    var name : String = ""
    /// MP3文件的名称
    var filename : String = ""
    /// 歌词文件的名称
    var lrcname : String = ""
    /// 歌手的名称
    var singer : String = ""
    /// 封面的图片名称
    var icon : String = ""
    
    /// KVC
    init(dict:[String:Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    //防止一些没有用到的key找不到属性而蹦
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
