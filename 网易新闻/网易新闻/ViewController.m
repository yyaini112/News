//
//  ViewController.m
//  网易新闻
//
//  Created by user on 17/2/14.
//  Copyright © 2017年 zichun. All rights reserved.
//

#import "ViewController.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height


@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) NSMutableArray *titleButtons;
@property (nonatomic,weak) UIButton *selectButton;
@property (nonatomic,weak) UIScrollView *titleScrollView;
@property (nonatomic,weak) UIScrollView *contentScrollView;
@property (nonatomic,assign) BOOL isInitialize;
@end

@implementation ViewController
- (NSMutableArray*) titleButtons
{
    if (_titleButtons == nil) {
        _titleButtons = [NSMutableArray array];
    }
    return _titleButtons;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isInitialize == NO) {
        // 4.设置所有标题
        [self setupAllTitle];
    }
    _isInitialize = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"网易新闻";
//    1.添加标题滚动视图
    [self setupTitleScrollView];
//    2.添加内容滚动视图
    [self setupContentScrollView];
   
    
    
   
    
    // 5.处理标题点击
    
    // 6.iOS7以后，导航条控制器中Scrollview顶部会添加64 额外的滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - 实现UIScrollViewDelegate方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //获取当前角标
    NSInteger i = scrollView.contentOffset.x / ScreenW;
    //获取标题按钮
    UIButton *titlrButton = self.titleButtons[i];
    //1.获取选中标题
    [self selButton:titlrButton];
    //2.把对应的子控制器的view添加上去
    [self setupOneViewController:i];
}
// 只要一滚动就需要字体渐变
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSInteger leftI = scrollView.contentOffset.x / ScreenW;
    NSInteger rightI = leftI + 1;
    
    //获取左边的按钮
    UIButton *leftBtn = self.titleButtons[leftI];
    NSInteger count = self.titleButtons.count;
    
    //获取右边的按钮
    UIButton *rightBtn;
    if (rightI < count) {
        rightBtn = self.titleButtons[rightI];
    }
    
    // 0-1 => 1~1.3
    CGFloat scaleR = scrollView.contentOffset.x / ScreenW;
    
    scaleR -= leftI;
    
    CGFloat scaleL = 1 - scaleR;
    
    // 缩放按钮
    leftBtn.transform = CGAffineTransformMakeScale(scaleL * 0.3 + 1, scaleL * 0.3 + 1);
    rightBtn.transform = CGAffineTransformMakeScale(scaleR * 0.3 + 1, scaleR * 0.3 + 1);
    
    // 颜色渐变
    UIColor *rightColor = [UIColor colorWithRed:scaleR green:0 blue:0 alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
}

#pragma mark - 选中标题
-(void)selButton:(UIButton *)button
{
    _selectButton.transform = CGAffineTransformIdentity;
    [_selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // 标题居中
    [self setupTitleCenter:button];
    
    // 字体缩放：形变
    button.transform =  CGAffineTransformMakeScale(1.3, 1.3);
    
    _selectButton = button;
}

#pragma mark - 标题居中
-(void)setupTitleCenter:(UIButton *)button
{
    // 本质：修改titleScrollview偏移量
    CGFloat offsetX = button.center.x - ScreenW * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - ScreenW;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}
#pragma mark - 添加一个子控制器的view
- (void)setupOneViewController:(NSInteger)i
{
    
    
    UIViewController *vc = self.childViewControllers[i];
    if (vc.view.superview) {
        return;
    }
    CGFloat x = i * ScreenW;
    vc.view.frame = CGRectMake(x, 0, ScreenW, self.contentScrollView.bounds.size.height);
    [self.contentScrollView addSubview:vc.view];

}

#pragma mark - 处理标题点击
-(void)titleClick:(UIButton *)button
{
    NSInteger i = button.tag;
    //1.标题颜色变成红色
    [self selButton:button];
    //2.把对应的子控制器的view添加上去
    [self setupOneViewController:i];
    
    //3.需要让titlescrollview可以滚动
    CGFloat x = i * ScreenW;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
}

#pragma mark - 设置所有标题
-(void)setupAllTitle
{
    //添加所有标题按钮
    NSInteger count = self.childViewControllers.count;
    CGFloat btnW = 100;
    CGFloat btnH = self.titleScrollView.bounds.size.height;
    CGFloat btnX = 0;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.tag = i;
        UIViewController *vc = self.childViewControllers[i];
        [titleButton setTitle:vc.title forState:UIControlStateNormal];
        btnX = i * btnW;
        titleButton.frame = CGRectMake(btnX, 0, btnW, btnH);
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // 监听按钮点击
        [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 把标题按钮保存到对应的数组里面
        [self.titleButtons addObject:titleButton];
        if (i == 0) {
            [self titleClick:titleButton];
        }
        
        [self.titleScrollView addSubview:titleButton];
    }
    //设置标题的滚动范围
    self.titleScrollView.contentSize = CGSizeMake(count * btnW, 0);
    //设置滚动条不可见
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    
    self.contentScrollView.contentSize = CGSizeMake(count * ScreenW, 0);
}



#pragma mark -  添加标题滚动视图
-(void)setupTitleScrollView
{
    //创建titleScrollview
    UIScrollView *titleScrollView = [[UIScrollView alloc] init];
    titleScrollView.backgroundColor = [UIColor whiteColor];
    CGFloat y = self.navigationController.navigationBarHidden? 20 : 64;
    titleScrollView.frame = CGRectMake(0, y, self.view.bounds.size.width, 44);
    [self.view addSubview:titleScrollView];
    _titleScrollView = titleScrollView;
    
}
#pragma mark - 添加内容滚动视图
-(void)setupContentScrollView
{
    //创建titleScrollview
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
   contentScrollView.backgroundColor = [UIColor greenColor];
    CGFloat y = CGRectGetMaxY(self.titleScrollView.frame);
    contentScrollView.frame = CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height-y);
    [self.view addSubview:contentScrollView];
    _contentScrollView = contentScrollView;
    
    // 设置contentScrollview的属性
    // 分页
    self.contentScrollView.pagingEnabled = YES;
    // 弹簧效果
    self.contentScrollView.bounces = NO;
    // 指示器
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    //设置代理，目的：监听内容滚动视图，什么时候滚动完成
    self.contentScrollView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
