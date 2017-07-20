# YJSliderView

## 简介
方便快捷轻量级的SlideView接入，模仿UITableView的API实现接口。使用Frame和约束布局都很方便。所有需要的就两个文件`YJSliderView`的头文件和实现文件。

### 结构简介

 * `title` `UICollectionView`
 	* SliderBar
 	* UICollectionViewCell
 		* UIButton 
 * `content` `UICollectionView`
 	* UICollectionViewCell
 		* UIView (属于外部控制器)
 


## 示例

![gif](http://o8ajh91ch.bkt.clouddn.com/Slider.gif)

新版样式(功能更加强大版本)：

![gif](https://github.com/HuyangJake/YJSliderView/blob/master/silderNew.gif?raw=true)

## 使用方法（就像使用UITableView）

1. 将`YJSliderView`的头文件和实现文件拷贝进自己的项目。
2. 在控制器中创建 YJSliderView的实例， 可以通过StoryBoard或者Frame。



3. 控制器遵守协议,按需实现代理方法 

``` objectivec
@interface IBBasicViewController ()<YJSliderViewDelegate> 
```

``` objectivec
@protocol YJSliderViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInYJSliderView:(YJSliderView *)sliderView;

- (UIView *)yj_SliderView:(YJSliderView *)sliderView viewForItemAtIndex:(NSInteger)index;

- (NSString *)yj_SliderView:(YJSliderView *)sliderView titleForItemAtIndex:(NSInteger)index;

@optional

- (NSInteger)initialzeIndexFoYJSliderView:(YJSliderView *)sliderView;


@end
```
* 	具体的代码和注意点详见Demo代码~


## 更新日志
* 2017.05.23 首次提交
* 2017.06.30 添加IB的展示
* 2017.07.20 更新滚动条和标题样式
	* title的宽度可根据内容来自动调整
	* 头部的滚动指示条的长度根据标题内容自动调整 