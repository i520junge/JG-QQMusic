//
//  MusicTools.swift
//  03-音乐播放
//
//  Created by 刘军 on 2016/11/25.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit
import AVFoundation

class MusicTools {
    
    /// 定义类属性，供下面类方法使用
    fileprivate static var player:AVAudioPlayer?
}

//MARK:- 播放音乐基本操作
extension MusicTools{
    
    /// 播放音乐
    /// - Parameter musicName: 音乐名称.音乐格式
    class func playMusic(_ musicName:String){
//        1、根据传入的名称，从包中获取对应的URL
        guard let url = Bundle.main.url(forResource: musicName, withExtension: nil) else{return}//要守护一下，万一传入的音乐找不到呢
        
//        2、判断和之前暂停&停止的音乐是否是同一首歌曲，相同则继续播放，不同则重新创建播放对象播放
        if player?.url == url {
            player?.play()
            return
        }
//        3、根据URL,创建AVAudioPlayer对象
        guard let player = try? AVAudioPlayer(contentsOf: url) else{return}//这个方法会抛异常，所以要用try?，可选链
        self.player = player
        
//        4、播放音乐
        player.play()
    }
    
    
    /// 暂停
    class func pauseMusic(){
        player?.pause()
    }
    
    /// 停止
    class func stopMusic()->(){
        player?.stop()
        player?.currentTime = 0
    }
}

//MARK:- 其他方法
extension MusicTools{
    
    /// 改变音量
    /// - Parameter volum: 传入需要改变的音量
    class func changeVolum(volum:Float)->(){
        player?.volume = volum
    }
    
    /// 快进
    /// - Parameter speedTime: 每次快进多少时间
    class func fastForward(speedTime:TimeInterval)->(){
        player?.currentTime += speedTime
    }
    
    /// 获取歌曲总时间
    class func getDuretion() -> TimeInterval{
        return player?.duration ?? 0
    }
    
    /// 获取当前歌曲播放时间
    class func getCurrentTime()->(TimeInterval){
        return player?.currentTime ?? 0
    }
    
    /// 设置跳至currentTime去播放
    class func setCurrentTime(_ currentTime:TimeInterval)->(){
        player?.currentTime = currentTime
    }
}

//MARK:- 处理时间
extension MusicTools{
    /// 将时间转为04:12格式的字符创
    class func stringWithTime(_ time:TimeInterval)->(String){
        let minute = Int(time)/60
        let second = Int(time)%60
        
        return String(format: "%02d:%02d", minute,second)
    }
    
    class func setPlayerDelegate(_ delegate:AVAudioPlayerDelegate){
        player?.delegate = delegate
    }
}

