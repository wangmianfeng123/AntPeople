//
//  mainViewController.m
//  AntPeople
//  Created by 蜂尚网络 on 2017/11/16.
//  Copyright © 2017年 王绵峰. All rights reserved.
//


#import "mainViewController.h"
#import "orderTotalViewController.h"
#import "LoginViewController.h"
#import "GxqAlertView.h"
#import "myViewController.h"
#import "MSCustomTabBar.h"
#import "resultModel.h"
#import "customUpdateView.h"
#import "BtPapawView.h"


@interface mainViewController ()<MSTabBarViewDelegate>
{
//    NSTimer *_timer;
    resultModel *_resultModel;
}

@property (nonatomic, strong) orderTotalViewController * orderTotalVC;
@property (nonatomic, strong) myViewController * myViewC;

@end


@implementation mainViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiNoti:) name:@"wifi_" object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    VIEW_BACKCOLOR
    BtAccount * bt = [BtAccountTool account];
    if (bt) {
        _resultModel = [resultModel mj_objectWithKeyValues:bt];
    }
    CGFloat heightCycle = 0.5;
    UIColor * color = [UIColor colorWithRed:253/255.0 green:225/255.0 blue:40/255.0 alpha:1.0];
    //利用kvc使用自定义的bar
    MSCustomTabBar * customBar = [[MSCustomTabBar alloc] init];
    //去掉tabbar顶部的线
    [customBar setBackgroundImage:[UIImage imageWithColor:[networkTool colorWithHexString:@"#ffffff"] size:CGSizeMake(SCREEN_WIDTH, heightCycle)]];
    //tabbar添加阴影
    [customBar shadowWithColor:color shadowOffSet:CGSizeMake(0, -5) shadowOpacity:0.1];
    [customBar setShadowImage:[UIImage new]];
    customBar.tabBarView.viewDelegate = self;
    [self setValue:customBar forKey:@"tabBar"];
    [self addAllChildViewController];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//          [BtPapawView showPapawView];
//    });
}


- (void)wifiNoti:(NSNotification *)noti{
    [SVProgressHUD showErrorWithStatus:@"当前网络异常，请检查网络连接"];
}

- (void)msTabBarView:(MSTabBarView *)view didSelectItemAtIndex:(NSInteger)index{
    self.selectedIndex = index;
}


- (void)msTabBarViewDidClickCenterItem:(MSTabBarView *)view
{
    beginOrderViewController * begin = [[beginOrderViewController alloc] init];
    if (self.selectedIndex == 0) {
        [self.orderTotalVC.navigationController pushViewController:begin animated:YES];
    } else {
        [self.myViewC.navigationController pushViewController:begin animated:YES];
    }
}


- (void)addAllChildViewController{
    self.orderTotalVC = [[orderTotalViewController alloc] init];
    [self addChildViewController:self.orderTotalVC title:@"我的订单" imageNamed:@""];
    self.myViewC = [[myViewController alloc] init];
    [self addChildViewController:self.myViewC  title:@"我的" imageNamed:@""];
}


- (void)addChildViewController:(UIViewController *)controller title:(NSString *)title imageNamed:(NSString *)imageNamed{
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.navigationItem.title = title;
    [self addChildViewController:navc];
}


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
