//
//  BtPapawView.m
//  ScrapMaster
//
//  Created by BNT-FS01 on 2018/4/26.
//  Copyright © 2018年 BNT-FS01. All rights reserved.
//

#import "BtPapawView.h"
#import "unFinishOrderController.h"
//#import "orderTotalViewController.h"
//#import "BtPriceDesViewController.h"

static CGFloat papawViewWidth = 100.f;
static CGFloat papawViewMinY = 150.f;

@interface BtPapawView()

@property (nonatomic, strong) UIView *papView;

@property (nonatomic, strong) NSTimer *papawTimer;

@property (nonatomic, assign) BOOL hiddenPapaw;
@property (nonatomic, assign) BOOL papawDirect;// NO:left YES:right

@property (nonatomic, strong) UILabel *orderNumLabel;


@end


@implementation BtPapawView

+ (instancetype)sharedPapawView
{
    static BtPapawView *btPapView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        btPapView = [[BtPapawView alloc] init];
    });
    return btPapView;
}


+ (void)showPapawView
{
    BtPapawView *btPapView = [BtPapawView sharedPapawView];
    [[UIApplication sharedApplication].keyWindow addSubview:btPapView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:btPapView];
    [btPapView configPapawTimer];
    
}

+ (void)refreshPapawOrderNumber:(NSInteger)papawNum
{
    if (papawNum > 0) {
        [BtPapawView sharedPapawView].orderNumLabel.text = [NSString stringWithFormat:@"%ld", papawNum];
        [BtPapawView showPapawView];
    } else {
        [BtPapawView sharedPapawView].orderNumLabel.text = @"0";
        [BtPapawView dismissPapawView];
    }
}

+ (void)dismissPapawView
{
    [[BtPapawView sharedPapawView] removeFromSuperview];
}

- (instancetype)init//新订单float_icon
{
    self = [super init];
    if (self) {
        self.papawDirect = YES;
        self.frame = CGRectMake(SCREEN_WIDTH - papawViewWidth - 10.f, papawViewMinY, papawViewWidth, papawViewWidth);
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, papawViewWidth, papawViewWidth)];
        imgV.image = [UIImage imageNamed:@"新订单float_icon"];
        [self addSubview:imgV];
        
        _orderNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, papawViewWidth, papawViewWidth)];
        _orderNumLabel.text = @"0";
        _orderNumLabel.textColor = [networkTool colorWithHexString:@"#333333"];
        _orderNumLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_orderNumLabel];
        
        self.layer.cornerRadius = papawViewWidth / 2.f;
        self.layer.masksToBounds = YES;
        
        _papView = [[UIView alloc] initWithFrame:self.bounds];
        _papView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [_papView addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [_papView addGestureRecognizer:panGesture];
        [self addSubview:_papView];
        self.hiddenPapaw = NO;
    }
    return self;
}


// tap Gesture
- (void)tapGestureAction:(UIGestureRecognizer *)tapGesture
{
    if (self.hiddenPapaw) {
        [self horizonMovePapawView];
    } else {
        [self configPapawTimer];
        unFinishOrderController *orderTotal = [[unFinishOrderController alloc] init];
//        priceDesVC.colorPaper = NO;
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVC = (UINavigationController *)rootVC;
            if ([navVC.topViewController isKindOfClass:[unFinishOrderController class]]) {
                [navVC popViewControllerAnimated:YES];
            } else {
                [navVC pushViewController:orderTotal animated:YES];
            }
        }
    }
}


// pan Gesture
- (void)panGestureAction:(UIGestureRecognizer *)panGesture
{
    CGPoint panPoint = [panGesture locationInView:[UIApplication sharedApplication].keyWindow];
    self.hiddenPapaw = NO;
    self.alpha = 1.f;
    self.center = panPoint;
    papawViewMinY = panPoint.y - papawViewWidth / 2.f;
    if (papawViewMinY < 64) {
        papawViewMinY =64;
    } else if (papawViewMinY > SCREEN_HEIGHT - papawViewWidth - 24) {
        papawViewMinY = SCREEN_HEIGHT - papawViewWidth - 24;
    }
    if (panPoint.x > SCREEN_WIDTH / 2.f) {
        self.papawDirect = YES;
    } else {
        self.papawDirect = NO;
    }
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self configPapawTimer];
        [UIView animateWithDuration:0.15f animations:^{
            CGFloat papVX = 10.f;
            if (self.papawDirect) {
                papVX = SCREEN_WIDTH - papawViewWidth - 10.f;
            }
            self.frame = CGRectMake(papVX, papawViewMinY, papawViewWidth, papawViewWidth);
        }];
    }
    
}

- (void)configPapawTimer
{
    [self.papawTimer invalidate];
    if (@available(iOS 10.0, *)) {
        self.papawTimer = [NSTimer scheduledTimerWithTimeInterval:5.f repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self papawTimerAction];
        }];
    } else {
        self.papawTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(papawTimerAction) userInfo:nil repeats:NO];
    }
}

- (void)papawTimerAction
{
    self.hiddenPapaw = YES;
    [self.papawTimer invalidate];
    [UIView animateWithDuration:0.35f animations:^{
        CGFloat papVX = -papawViewWidth / 2.f;
        if (self.papawDirect) {
            papVX = SCREEN_WIDTH - papawViewWidth / 2.f;
        }
        self.frame = CGRectMake(papVX, papawViewMinY, papawViewWidth, papawViewWidth);
        self.alpha = 0.5f;
    }];
    
}

- (void)horizonMovePapawView
{
    self.hiddenPapaw = NO;
    [self configPapawTimer];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1.f;
        CGFloat papVX = 10.f;
        if (self.papawDirect) {
            papVX = SCREEN_WIDTH - papawViewWidth - 10.f;
        }
        self.frame = CGRectMake(papVX, papawViewMinY, papawViewWidth, papawViewWidth);
    } completion:^(BOOL finished) {
        
    }];
    
}



@end
