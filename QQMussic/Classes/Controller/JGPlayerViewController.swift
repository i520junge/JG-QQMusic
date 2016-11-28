//
//  JGPlayerViewController.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/26.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class JGPlayerViewController: UIViewController {
    //MARK:- 控件属性
    @IBOutlet weak var bgimageView: UIImageView!    //背景
    @IBOutlet weak var iconImageView: UIImageView!  //歌曲图片
    @IBOutlet weak var songLabel: UILabel!              //歌名
    @IBOutlet weak var singerLabel: UILabel!            //歌手
    @IBOutlet weak var lrcLabel: JGLrcLabel!               //歌词
    @IBOutlet weak var currentTimeLabel: UILabel!     //当前播放时间
    @IBOutlet weak var totalTimeLabel: UILabel!         //总播放时间
    @IBOutlet weak var progressSlider: UISlider!           //播放进度
    @IBOutlet weak var playOrPauseBtn: UIButton!       //播放或暂停按钮
    @IBOutlet weak var lrcScrollView: JGLrcScrollView!//装全部歌词
    
    //MARK:- 存储属性
    fileprivate lazy var musicDatas:[JGMusicModel] = [JGMusicModel]()
    fileprivate var currentMusic:JGMusicModel!          //记录当前要播放哪首歌
    fileprivate var progressTimer:Timer?                     //进度定时器
    fileprivate var lrcTimer:CADisplayLink?                 //歌词定时器
    
    //MARK:- 初始化操作
    override func viewDidLoad() {
        super.viewDidLoad()
//        1、设置界面
        setUpUI()
        
//        2、加载数据
        loadMusicData()
        
//        3、展示一首音乐的信息
        currentMusic = musicDatas[Int(arc4random_uniform(UInt32(musicDatas.count)))]
        updateMusicInfo()
        iconImageView.layer.pauseAnim()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        lrcScrollView.setLrcScrollViewTableViewContentOffset()
    }
    
    deinit {
        removeLrcTimer()
        removeProgressTimer()
    }
}

//MARK:- 设置界面
extension JGPlayerViewController{
    fileprivate func setUpUI(){
//        1、背景添加毛玻璃效果
        setupBlurView()
        
//        2、设置滑块背景
        progressSlider.setThumbImage(UIImage(named:"player_slider_playback_thumb"), for: .normal)
        
//        3、设置iconImageView为圆角
        setIconImageViewCornerRadius()
        
//        4、设置歌词的view代理，滑动隐藏图片和歌词
        lrcScrollView.delegate = self
        lrcScrollView.lrcDelegate = self
        
        
    }
    
    fileprivate func setupBlurView(){
        //创建毛玻璃UIVisualEffectView，指定effect:UIBlurEffect为什么颜色
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        //设置frame
        blurView.frame = kScreenWH
        //添加到bgimageView上
        bgimageView.addSubview(blurView)
    }
    
    fileprivate func setIconImageViewCornerRadius(){
        iconImageView.layer.cornerRadius = kIconImageViewW*0.5
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.borderWidth = 8 //设置边宽
        iconImageView.layer.borderColor = UIColor.black.cgColor //属性是CGColor，所以要转
    }
    
    /// 设置状态栏风格
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
}

//MARK:- 加载歌曲数据
extension JGPlayerViewController{
    fileprivate func loadMusicData(){
//        1、获取plist文件路径
        let plistPath = Bundle.main.path(forResource: "Musics.plist", ofType: nil)
        
//        2、用数组接收plist文件数据
        guard let musicArr = NSArray(contentsOfFile: plistPath!) as? [[String:Any]] else{return}    //swift中Array没有解析plist文件的方法，所以用OC中的NSArray，然后在转为swift中的字典数组
        
//        3、将数据转模型
        for dict in musicArr{
            musicDatas.append(JGMusicModel(dict: dict))
        }
    }
}

//MARK:- 随着歌曲更新UI界面
extension JGPlayerViewController{
    fileprivate func updateMusicInfo(){
//        0、取出那首歌
        let music = currentMusic!
        if playOrPauseBtn.isSelected {
            MusicTools.playMusic(music.filename)
            MusicTools.setPlayerDelegate(self)
        }
        
//        1、改变界面内容
        bgimageView.image = UIImage(named: music.icon)
        iconImageView.image = UIImage(named: music.icon)
        songLabel.text = music.name
        singerLabel.text = music.singer
        
        
//        2、修改显示时间
        currentTimeLabel.text = MusicTools.stringWithTime(MusicTools.getCurrentTime())
        totalTimeLabel.text = MusicTools.stringWithTime(MusicTools.getDuretion())
        
//        3、添加更新进度的定时器
        addProgressTimer()
        
//        4、给IconImageView添加动画
        addRotationAnim()
        
//        5、将歌词文件出入scrollView中展示
        lrcScrollView.lrcName = currentMusic.lrcname
        
//        6、添加歌词定时器
        removeLrcTimer()    //每次添加定时器前都先移除之前的定时器
        addLrcTimer()
        
//        7、更新锁屏界面信息
        setupLockInfo(UIImage(named: currentMusic.icon))
    }
    
    fileprivate func addRotationAnim(){
        //1、创建动画
        let rotationAni = CAAnimation.rotationAnim()
        
        //3、添加动画
        iconImageView.layer.add(rotationAni, forKey: nil)
    }
}

//MARK:- 进度条定时器操作
extension JGPlayerViewController{
    
    /// 更新进度条的定时器
    fileprivate func addProgressTimer(){
        progressTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)   //每1.0秒更新一次
        RunLoop.main.add(progressTimer!, forMode: .commonModes)  //手动添加至运行循环
    }
    
    /// 移除进度条的定时器
    fileprivate func removeProgressTimer(){
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    /// 更新进度条
    @objc fileprivate func updateProgress(){
        // 更新当前播放时间
        currentTimeLabel.text = MusicTools.stringWithTime(MusicTools.getCurrentTime())
        // 更新进度条 = 当前歌曲播放到时间/歌曲总时间
        progressSlider.value = Float(MusicTools.getCurrentTime()/MusicTools.getDuretion())
    }
}

//MARK:- 进度条操作
extension JGPlayerViewController{
    //按下滑块开始拖动时，进度定时器不再运行
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        removeProgressTimer()
    }
    //拖动滑块
    @IBAction func sliderValueChange(_ sender: UISlider) {
        //①获取当前进度的时间
        let time = Double(progressSlider.value)*MusicTools.getDuretion()
        //②更新播放时间
        currentTimeLabel.text = MusicTools.stringWithTime(time)
    }
    //拖动滑块松手
    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
       sliderUpdateCurrentTime()
    }
    //拖动着滑块出去了松手
    @IBAction func sliderTouchUpOutside(_ sender: UISlider) {
        sliderUpdateCurrentTime()
    }
    
    // 点按手势会触发这个方法
    @IBAction func sliderTapGes(_ sender: UITapGestureRecognizer) {
        //①获取手势的点
        let point = sender.location(in: progressSlider)
        //②根据点获取比例
        let retio = point.x/progressSlider.bounds.width
        //③根据比例，改变歌曲进度
        let time = Double(retio)*MusicTools.getDuretion()
        MusicTools.setCurrentTime(time) //让歌曲播放到这里
        updateProgress()         //马上更新播放时间和进度条
    }
    
    fileprivate func sliderUpdateCurrentTime(){
        //①、获取当前进度时间
        let time = Double(progressSlider.value)*MusicTools.getDuretion()
        //②、让当前滑动到的时间，做为开始播放的时间
        MusicTools.setCurrentTime(time)
        //③、开启定时器
        addProgressTimer()
    }
}

//MARK:- 歌词定时器
extension JGPlayerViewController{
    fileprivate func addLrcTimer(){
        lrcTimer = CADisplayLink(target: self, selector: #selector(updateLrc))
        lrcTimer?.add(to: RunLoop.main, forMode: .commonModes)
    }
    fileprivate func removeLrcTimer(){
        lrcTimer?.invalidate()
        lrcTimer = nil
    }
    
    /// 定时器每1秒更新60次，把当前播放歌曲的时间传过去，显示这个时间的那句歌词
    @objc fileprivate func updateLrc(){
        lrcScrollView.currentTime = MusicTools.getCurrentTime()
    }
}


//MARK:- 播放/上一曲/下一曲
extension JGPlayerViewController{
    
    @IBAction func previousMusic() {
        switchMusic(isNext: false)
        
    }
    @IBAction func nextMusic() {
        switchMusic(isNext: true)
    }
    @IBAction func playOrPauseMusic(_ sender: UIButton) {
        //1、调整按钮状态
        playOrPauseBtn.isSelected = !playOrPauseBtn.isSelected
        //2、根据状态播放或暂停歌曲
        switch playOrPauseBtn.isSelected {
        case true:
            MusicTools.playMusic(currentMusic.filename)
            totalTimeLabel.text = MusicTools.stringWithTime(MusicTools.getDuretion())
            iconImageView.layer.resumeAnim()    //恢复动画
            MusicTools.setPlayerDelegate(self)
        default:
            MusicTools.pauseMusic()
            iconImageView.layer.pauseAnim()     //停止动画
        }
    }
    
    fileprivate func switchMusic(isNext:Bool){
//        1、根据当前播放歌曲，获取播放的第几首歌
        let currentIndex = musicDatas.index(of: currentMusic)!
        
//        2、获取上一首或下一首个的下标值
        var index = 0
        if isNext {
            index = currentIndex + 1
            if index > musicDatas.count - 1 {
                index = 0
            }
        }else{
            index = currentIndex - 1
            if index < 0 {
                index = musicDatas.count - 1
            }
        }
        
//        3、根据下标值取出整首歌的信息
        currentMusic = musicDatas[index]
        
//        4、播放这首歌
        updateMusicInfo()
    }
    
}

//MARK:- scrollView代理
extension JGPlayerViewController:UIScrollViewDelegate,JGLrcScrollViewDelegate{
    // 拖动时慢慢隐藏图片
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 获取拖动时相对于屏幕的比例
        let retio = scrollView.contentOffset.x/kScreenW
        iconImageView.alpha = 1 - retio
        lrcLabel.alpha = 1 - retio
    }
    
    // 画歌词
    func lrcScrollView(_ lrcScrollView: JGLrcScrollView, lrcString: String, progress: Double) {
        lrcLabel.text = lrcString
        lrcLabel.shading = progress
    }
    
    func lrcScrollView(_ lrcScrollView: JGLrcScrollView, _ strArr: [String]) {
        // 1.获取封面图片
        guard let image = UIImage(named: currentMusic.icon) else { return }
        
        // 2.根据图片尺寸,开启上下文
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        
        // 3.先将图片画到上下文
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        // 4.上一句、当前句，下一句
        for i in 0..<strArr.count{
            let str = strArr[i]
            if i == 1{
               JGLrcTool.drawLrcLine(str, image: image, fontSize: 17, textColor: UIColor.green, numbleLine: i+1)
            }else{
            JGLrcTool.drawLrcLine(str, image: image, fontSize: 15, textColor: UIColor.white, numbleLine: i+1)
            }
        }
        
        // 7.从上下文中获取图片
        let lrcImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 8.关闭上下文
        UIGraphicsEndImageContext()
        
        // 9.根据最新图片,设置锁屏界面的信息
        setupLockInfo(lrcImage)
    }

}



//MARK:- 播放完，自动下一首歌
extension JGPlayerViewController:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            nextMusic()
        }
    }
}


//锁屏信息
// MPMediaItemPropertyAlbumTitle
// MPMediaItemPropertyAlbumTrackCount
// MPMediaItemPropertyAlbumTrackNumber
// MPMediaItemPropertyArtist
// MPMediaItemPropertyArtwork
// MPMediaItemPropertyComposer
// MPMediaItemPropertyDiscCount
// MPMediaItemPropertyDiscNumber
// MPMediaItemPropertyGenre
// MPMediaItemPropertyPersistentID
// MPMediaItemPropertyPlaybackDuration
// MPMediaItemPropertyTitle

//MARK:- 锁屏界面播放音乐
extension JGPlayerViewController{
    /// 设置锁屏界面信息
    func setupLockInfo(_ musicImage:UIImage?){
//        1、获取锁屏中心（导入MediaPlayer框架）
        let centerInfo = MPNowPlayingInfoCenter.default()
        
//        2、设置锁屏对应位置显示信息
        var infoDict = [String:Any]()
        infoDict[MPMediaItemPropertyAlbumTitle] = currentMusic.name //歌曲名字
        infoDict[MPMediaItemPropertyArtist] = currentMusic.singer   //歌唱者
        infoDict[MPMediaItemPropertyPlaybackDuration] = MusicTools.getDuretion()//总时间
        infoDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = MusicTools.getCurrentTime() //当前播放的时间
        
        if let image = musicImage{  //绑定必须为可选
            infoDict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        }
        
        centerInfo.nowPlayingInfo = infoDict
//        3、让应用程序成为第一响应者
        UIApplication.shared.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()//开始接受远程操控
    }
    
    /// 设置对应按钮做什么事情
    override func remoteControlReceived(with event: UIEvent?) {
//        1、校验远程事件是否有值
        guard let event = event else{return}
        
//        2、处理远程事件
        switch event.subtype {
        case .remoteControlPlay,.remoteControlPause://播放暂停
            playOrPauseMusic(playOrPauseBtn)
        case .remoteControlNextTrack://下一曲
            nextMusic()
        case .remoteControlPreviousTrack://上一曲
            previousMusic()
        default:
            print("-----")
        }
    }
}

