# JG-QQMusic
##高仿QQ音乐，封装了播放音乐、处理歌词、处理动画的工具类

##效果图
[![IMG_0081.png](http://image.huangbowei.com/images/2016/11/28/IMG_0081.png)](http://image.huangbowei.com/image/MyZY)
[![QQ.gif](http://image.huangbowei.com/images/2016/11/28/QQ.gif)](http://image.huangbowei.com/image/MOcq)
##主要功能如下：

###一.新建项目,进行基本设置
1.修改displayName
2.修改部署版本
3.横竖屏支持
4.设置应用程序图片/启动图片
5.划分目录结构


###二.给控制器的View添加背景
1.在storyboard中添加imageView
2.给imageView上层添加毛玻璃效果
* •	UIToolBar
* •	UIVisualEffectView
* •	CoreImage  -> 二维码
* •	GPUImage

###三.布局界面
1.直接预习代码中,拷贝出来界面布局
2.细节调整
* •	iconImageView —> 和bgImageView的宽度相等
3.设置UISLider的滑块的图片
* slider.setThumeImage()
4.设置状态栏的颜色
* 重写statusStyle属性  —> lightContent

###四.加载歌曲数据
* 从plist文件中取出数据
* 转成模型对象,并且放入到数组中

###五.播放歌曲
1.从之前的项目将MusicTools的工具类拿过来
2.随机了一首歌曲进行播放


###六.播放某一首歌曲,将界面的信息,进行修改
1.改变界面的信息
* •	背景图片
* •	iconImageView
* •	songLabel
* •	singerLabel
2.当前时间/总时间/progressSlider
* •	当前时间: 00:00
* •	总时间: 对MusicTools提供一个可以获取总时长的函数
* •	将时间转成: 04:12
* •	progressSlider.value = 0

###七.随着歌曲的播放, 改变进度
1.添加定时器
* •	定义progressTimer属性
* •	定义addProgressTimer()
* •	定义removeProgressTimer()
* •	在监听方法中更新内容: 左边当前时间的Label/slider的value


###八.滑块/点击UISlider,改变歌曲的进度
1.touchDown
* •	移除定时器
2.valueChange
* •	改变当前时间 —> 根据value * duration
3.touchUpside/outSide
* •	播放该位置的歌曲
* •	添加定时器
4.给UISlider添加手势
* •	在storyboard
* •	监听手势
* •	获取点击位置对应的比例 * duration
* •	设置播放该位置的时间
* •	更新当前时间Label/UISlider的value

###九.上一首/下一首/播放/暂停
1.上一首
* •	获取当前歌曲的index
* •	index - 1
* •	判断越界问题
* •	取出上一首歌曲
* •	播放该歌曲
2.下一首
* •	同上
3.暂停&播放歌曲
* •	改变btn的isSelected状态
* •	根据状态,判断需要暂停歌曲,还是播放歌曲
4.暂停&恢复核心动画
* •	获取OC代码
* •	转成Swift
* •	封装到CALayer的extension


###十.添加歌词的View
1.在storyboard中添加UIScrollView
* •	并且给UIScrollView设置约束
* •	在代码中设置UIScrollView的contentSize
* •	设置UIScrollView的代理
* •	监听UIScrollView的滚动, 根据滚动多少,设置iconImageview/LrcLabel的alpha值
2.自定义UIScrollView
* •	添加UITableView用于展示歌词
* •	设置UITableView属性
* •	设置UITableViewCell属性 —> 自定义Cell

###十一.获取歌词的名称,并且解析歌词
1.获取歌词的名称
* •	在自定义LRcScrollView中提供lrcname的属性
* •	外界播放新歌词的时候,将新lrcname传入进来
2.解析歌词
* •	封装lrcTools工具类
* •	工具类对外提供解析的方法
* •	将歌词解析成LrclineModels
* •	使用String读取整个lrc文件
* •	通过\n切割一句句歌词
* •	过滤掉不需要的行数
* •	将每一句歌词转成模型对象
3.使用UITableView展示每一句歌词


###十二.根据当前播放的时间,展示对应句的歌词
1.在控制器中添加定时器
* •	lrcTimer : CADisplaylink
* •	添加定时器方法
* •	移除定时器方法
* •	实时将时间,传递给lrcScrollView
2.拿到currentTime
* •	遍历所有的歌词
* •	取出i位置的歌词/i+1位置的歌词
* •	判断时间是大于i位置的时间,并且小于i+1位置的时间,则显示i位置的歌词
3.为了防止该方法执行非常频繁
* •	记录i
* •	if currentLineIndex != i {}

###十三.Bug处理
1.第一次使用LrcScrollView时,tableView没有滚动到中间位置
* •	控制器的viewDidAppear中,给LrcScrollView中tableVIew设置位置
* viewDidload
* viewWillApear
* viewWillLayoutsubViews
* viewDidLayoutsubviews
* viewDidAppear
2.如果上一首,歌词更新到较大的数字时,切换歌词,程序会崩溃
* •	delete row but container 20
* •	currentLineIndex = 0

###十四.歌词进度展示
1.自定义LrcLabel
* 重写drawRect方法
2.将LrcViewCell中的Label换成LrcLabel
3.获取进度,并且将进度传递LrcLabel
* let progress = (当前时间-i位置的时间)/ (i+1位置时间-i位置时间)
* 传递给lrcLabel
* 根据progress获取到rect
* UIRectFill(rect, soundIn)


###十五.外界LrcLabel的显示
* 定义协议
* 定义代理属性
* 通知代理,并且将lrcText/progress传递到控制器
* 将控制器的lrcLale类型改成自定义LrcLabel类型
* 控制器设置lrcLabel的内容/progress
自动播放下一首歌：工具类提供设置代理方法

###十六.核心动画在推到后台时会移动
* •	isRemoveOnCompletion = false

###十七.后台播放

###十八.锁屏操控播放音乐

###十九.锁屏显示歌词
