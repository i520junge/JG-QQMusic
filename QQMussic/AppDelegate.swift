//
//  AppDelegate.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/26.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 开启后台播放功能
//        1、获取音频会话
        let session = AVAudioSession.sharedInstance()
        do {
//        2、设置音频可以后台播放(background modes中勾选audio，……)
            try session.setCategory(AVAudioSessionCategoryPlayback)
//        3、激活会话
            try session.setActive(true)
        } catch  {
            print(error)
        }
        
        return true
    }

}

