//
//  JGLrcScrollView.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/28.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit

private let kLrcCellID = "kLrcCellID"

/// 让外界可以拿到当前播放的这句歌词，和播放进度
protocol JGLrcScrollViewDelegate:class {
    func lrcScrollView(_ lrcScrollView:JGLrcScrollView,lrcString:String,progress:Double)
    /// 传歌词，当前句放在第2
    func lrcScrollView(_ lrcScrollView : JGLrcScrollView, _ strArr:[String])
}

class JGLrcScrollView: UIScrollView {
//MARK:- 内部属性
    fileprivate lazy var tableView:UITableView = UITableView()
    fileprivate var lrcLineModelArr:[JGLrcLineModel]?   //存放整首歌的歌词
    fileprivate var currentLineIndex = 0    //用于记录当前播放的哪句，防止定时器作用让currentTime里面操作多次，而损耗性能
    
//MARK:- 对外属性
    weak var lrcDelegate:JGLrcScrollViewDelegate?
    
/// 歌曲名字：外面一更新歌曲就告诉你歌曲名字，这里一拿到歌曲名字就加载歌曲的歌词和时间，并转为模型
var lrcName:String = ""{
        didSet{
            lrcLineModelArr = JGLrcTool.parseLrc(lrcName)   //加载数据，转为模型
            tableView.setContentOffset(CGPoint(x: 0, y: -bounds.height * 0.5), animated: false)
            tableView.reloadData()
            
            //每次播放一首新歌时，把当前播放句归零，防止还记录着上一首歌的，
            currentLineIndex = 0
        }
    }

/// 让歌词按照当前播放时间滚动到对应位置
    var currentTime:TimeInterval = 0{
        didSet{
            //1、校验歌词是否有值
            guard let lrcLineModelArr = lrcLineModelArr else{return}
            
            //2、遍历所有歌词
            let count = lrcLineModelArr.count
            for i in 0..<count{
                
            //3、取出一句歌词和这句歌词的下一句歌词
                let lrcLine = lrcLineModelArr[i]
                guard i+1 < count-1 else{continue}
                let nextLrcLine = lrcLineModelArr[i+1]
                
            //4、判断当前时间是否是在这2句歌词的时间内，
                if currentTime >= lrcLine.lrcTime && currentTime < nextLrcLine.lrcTime && i != currentLineIndex {
                    
            //5、是的话就刷新上一句和这一句的歌词，且tabbleView滚动到这句歌词
                    //①取出上一句和这一句对应的indexPath
                    let preIndexPath = IndexPath(row: currentLineIndex, section: 0)
                    let indexPath = IndexPath(row: i, section: 0)
                    //②记录当前播放的第几句
                    currentLineIndex = i
                    //③刷新上一句、下一句的cell
                    tableView.reloadRows(at: [preIndexPath,indexPath], with: .none)
                    //④tabbleView滚动到i这句
                    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    //⑤画出最新歌词
                    drawLrcImage()
                }
                
            //6、画出正在播放的那句歌词
                guard i == currentLineIndex else{continue}
                //①计算当前时间 与这句歌词播放的总时间的比例
                let progress = (currentTime - lrcLine.lrcTime)/(nextLrcLine.lrcTime - lrcLine.lrcTime)
                //②取出这句歌词对应的cell，对其进行渐变处理
                let currentIndexPath = IndexPath(row: i, section: 0)
                guard let currentCell = tableView.cellForRow(at: currentIndexPath) as? JGLrcCell else{continue}
                currentCell.lrcLabel.shading = progress
                
                //③将播放的这句歌词传出去
                lrcDelegate?.lrcScrollView(self, lrcString: lrcLine.lrcString, progress: progress)
            }
        }
    }
    
    func setLrcScrollViewTableViewContentOffset() {
        tableView.setContentOffset(CGPoint(x: 0, y: -bounds.height * 0.5), animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //初始化UI界面
        setUpUI()
    }
}


//MARK:- UI界面
extension JGLrcScrollView{
    fileprivate func setUpUI(){
        //设置自身属性
        contentSize = CGSize(width: 2*kScreenW, height: 0)
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        // 添加tabbleView
        addSubview(tableView)
        tableView.register(JGLrcCell.self, forCellReuseIdentifier: kLrcCellID)
        tableView.dataSource = self
        tableView.frame = CGRect(x: kScreenW, y: 0, width: kScreenW, height: bounds.height)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        //让歌词顶部和底部能拖到中间显示
        tableView.contentInset = UIEdgeInsets(top: bounds.height*0.5, left: 0, bottom: bounds.height*0.5, right: 0)
        tableView.rowHeight = 35
    }
}

//MARK:- tableView数据源
extension JGLrcScrollView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lrcLineModelArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kLrcCellID, for: indexPath) as? JGLrcCell
        //文字颜色显示
        if indexPath.row == currentLineIndex {
            cell?.lrcLabel.font = UIFont.systemFont(ofSize: 17)
        }else{
            cell?.lrcLabel.font = UIFont.systemFont(ofSize: 14)
            cell?.lrcLabel.shading = 0      //防止这句也画
        }
        //显示歌词
        let lrcLineModel = lrcLineModelArr?[indexPath.row]
        cell?.lrcLabel.text = lrcLineModel?.lrcString
        
        return cell!
    }
}

// MARK:- 画出三句歌词
extension JGLrcScrollView {
    fileprivate func drawLrcImage() {
        // 1.取出三句歌词
        // 1.1.取出本句歌词
        let currentLrcText = lrcLineModelArr![currentLineIndex].lrcString
        // 1.2.取出上一句歌词
        var previousLrcText = ""
        if currentLineIndex - 1 >= 0 {
            previousLrcText = lrcLineModelArr![currentLineIndex - 1].lrcString
        }
        var prepreviousLrcText = ""
        if currentLineIndex - 2 >= 0 {
            prepreviousLrcText = lrcLineModelArr![currentLineIndex - 2].lrcString
        }
        // 1.3.取出下一句歌词
        var nextLrcText = ""
        if currentLineIndex + 1 <= lrcLineModelArr!.count - 1 {
            nextLrcText = lrcLineModelArr![currentLineIndex + 1].lrcString
        }
        
        // 2.将三句歌词回调给外界控制器
        lrcDelegate?.lrcScrollView(self, [nextLrcText,currentLrcText,previousLrcText,prepreviousLrcText])
    }
}

