# YJSliderView

## 简介
方便快捷轻量级的SlideView接入，模仿UITableView的API实现接口。使用Frame和约束布局都很方便。所有需要的就两个文件`YJSliderView`的头文件和实现文件。

### 结构简介
 标题和内容分别为两个`UICollectionView`

## 示例

![gif](http://o8ajh91ch.bkt.clouddn.com/Slider.gif)

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

## 改进点
* 没有实现不同页面的重用机制（貌似也非必须？）
* 修改了切换页面后，title会闪一下的问题后。title的颜色渐变有点突兀

## 更新日志
* 2017.05.23 首次提交
* 2017.06.30 添加IB的展示