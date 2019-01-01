//
//  ViewController.m
//  图片截取
//
//  Created by 赵鹏 on 2019/1/1.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIView *clipView;  //截取View
@property (assign, nonatomic) CGPoint startPoint;  //手指在屏幕上拖动时候的起始点

@end

@implementation ViewController

#pragma mark ————— 懒加载 —————
- (UIView *)clipView
{
    if (_clipView == nil)
    {
        _clipView = [[UIView alloc] init];
        _clipView.backgroundColor = [UIColor blackColor];
        _clipView.alpha = 0.5;
        
        [self.view addSubview:_clipView];
    }
    
    return _clipView;
}

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //在屏幕上添加一个拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    [self.view addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    //手指在屏幕上拖动时候的终止点
    CGPoint endPoint = CGPointZero;
    
    if (pan.state == UIGestureRecognizerStateBegan)  //手指刚开始在屏幕上拖动的时候
    {
        //利用"locationInView:"方法来获取手指触碰屏幕的位置
        self.startPoint = [pan locationInView:self.view];
    }else if (pan.state == UIGestureRecognizerStateChanged)  //手指一直拖动的时候
    {
        endPoint = [pan locationInView:self.view];
        
        //手指拖动形成的矩形的宽度
        CGFloat rectangularWidth = endPoint.x - self.startPoint.x;
        
        //手指拖动形成的矩形的高度
        CGFloat rectangularHeight = endPoint.y - self.startPoint.y;
        
        //获取手指拖动形成的矩形的尺寸
        CGRect clipViewRect = CGRectMake(self.startPoint.x, self.startPoint.y, rectangularWidth, rectangularHeight);
        
        /**
         设置截取View的尺寸：
         截取View就是手指拖动形成的矩形。
         */
        self.clipView.frame = clipViewRect;
    }else if (pan.state == UIGestureRecognizerStateEnded)  //手指停止拖动的时候
    {
        /**
         1、创建一个与UIImageView控件大小相同的基于位图(bitmap)的图形上下文：可以把图形上下文看成是一个画板，以后所绘制的内容都画在这个画板上。
         size参数：图形上下文的尺寸；
         opaque参数：不透明度（YES：不透明；NO：透明）；
         scale参数：缩放比例。
         */
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
        
        /**
         2、利用贝塞尔路径设置要裁剪的区域（手指拖动形成的矩形）：
         */
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.clipView.frame];
        
        [path addClip];
        
        /**
         3、获取图形上下文：
         */
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        /**
         4、把UIImageView控件上的图层渲染到图形上下文中：
         图层(layer)只能渲染，不能绘制。
         */
        [self.imageView.layer renderInContext:ctx];
        
        /**
         5、从图形上下文中取出截取好的图片：
         */
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        /**
         6、把截取好的图片显示在UIImageView控件上：
         */
        self.imageView.image = image;
        
        /**
         7、关闭图形上下文：
         */
        UIGraphicsEndImageContext();
        
        /**
         8、移除截取View：
         */
        [self.clipView removeFromSuperview];
    }
}

@end
