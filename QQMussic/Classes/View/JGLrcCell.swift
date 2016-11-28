//
//  JGLrcCell.swift
//  QQMussic
//
//  Created by 刘军 on 2016/11/28.
//  Copyright © 2016年 刘军. All rights reserved.
//

import UIKit

class JGLrcCell: UITableViewCell {
    lazy var lrcLabel:JGLrcLabel = JGLrcLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 将自定义的lrcLabel添加到cell中
        contentView.addSubview(lrcLabel)
        
        // 一些一次性操作，直接放在数据源方法，会调用多次，性能不好
        lrcLabel.textColor = UIColor.white
        lrcLabel.textAlignment = .center
        backgroundColor = UIColor.clear
        lrcLabel.font = UIFont.systemFont(ofSize: 15)
        
        // 让cell点击时不会变化，不能设置为无法与用户交互，不然无法拖动
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置lrcLabel的frame
        lrcLabel.sizeToFit()
        lrcLabel.center = contentView.center
    }
}
