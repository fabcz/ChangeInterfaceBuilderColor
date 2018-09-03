# ChangeInterfaceBuilderColor
一键修改 xib storyboard 控件颜色空间(colorSpace) 
## 缘起：
设计那边出了个缺省页的图然后还标注了按钮的色值，然后我这边也照常写了，但多次沟通后设计还是说那颜色看起来不对（我看都长得一样啊，设计自带像素眼？）
## 排查：
于是乎我打开 XIB 文件看看，确实是设置的 0099E8 呀，因为我没有像素眼，只能借助外部工具来看看实际运行起来色值是多少，然后我借助 [FLEX](https://github.com/Flipboard/FLEX) 这个工具看了下色值，神奇的是实际出来的色值变成了 00AAEC（图一）
![图一](https://upload-images.jianshu.io/upload_images/1615548-cdc538c780fc9721.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 解决：
经过一顿操作[（我是一顿操作）](https://stackoverflow.com/questions/10039641/ios-color-on-xcode-simulator-is-different-from-the-color-on-device#new-answer)最终定位到问题是电脑的颜色空间不一致导致的问题（想起之前因为 iMac 投出的副屏不清晰然后给 iMac 装了特定的颜色文件），然后再次打开 XIB 查看颜色空间确实不是常用的 sRGB 而是 Generic RGB（图二），然后把颜色空间改成 sRGB 后跑起来色值正常了，设计也露出了满意且邪魅的笑容。
![图二](https://upload-images.jianshu.io/upload_images/1615548-641b92cbb07a6805.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 反思：
但这样真的解决了吗？是解决了，但解决的只是这个按钮的色值问题，项目中还有其它地方有这个问题吗？好，写个 Demo 来排查下，于是又经过[一顿操作](https://github.com/fabcz/ChangeInterfaceBuilderColor)这个 Mac 应用出来了，主要可以根据色值匹配列出项目中所有的元素，然后一键替换或部分替换，还有个隐藏功能就是可以将项目中某个色值替换成指定色值（换肤）。最终发现项目中有 **245** 个用 GenericRGB 颜色空间导致有色差的地方（图三），然后进行一一替换。
![图三](https://upload-images.jianshu.io/upload_images/1615548-4f03ec71d428a175.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 总结：
- 色值出现偏差是因为 sketch 默认的颜色配置文件是 sRGB IEC61966-2.1（图四），而 Xcode8 之前是 generic RGB，Xcode8 之后才统一为 sRGB IEC61966-2.1
- 代码编写的 UIColor 颜色空间默认是 sRGB 的
- 为了避免出现颜色偏差的问题，最优方案应该是跟设计那边沟通统一颜色配置文件，毕竟颜色配置文件也是不断发展的，谁知道若干年后 sRGB 是不是也过时了呢！
![图四](https://upload-images.jianshu.io/upload_images/1615548-dcc738dc11a10238.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
