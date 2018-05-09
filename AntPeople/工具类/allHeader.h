//
//  allHeader.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/15.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#ifndef allHeader_h
#define allHeader_h



#import "GJJBlockDefines.h"
#import "UIViewController+aletView.h"
#import "networkService.h"
#import "AESSecurityUtil.h"
#import <UIImage+GIF.h>
#import "NetWorking.h"
#import <MJRefresh.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "getOrderViewController.h"
#import "UIButton+btncategory.h"
#import "UIView+viewCategory.h"
#import "UIImage+imageshadow.h"
#import "networkTool.h"
#import <Masonry.h>
#import "StarsView.h"
#import "BtAccountTool.h"
#import "gaodeMapNavViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <MJExtension.h>
#import "tradingModel.h"
#import <UIImageView+WebCache.h>
#import <SDWebImage/SDImageCache.h>
#import "UIViewController+BarButton.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "beginOrderViewController.h"
#import "orderDetailViewController.h"
#import "MSCustomTabBar+shadowCategory.h"
#import "UIBarButtonItem+barButtonCategory.h"
#import "UITextField+fieldFieldPlaceColor.h"
#import "BtPushManagerTool.h"
#import "UIViewController+SXFullScreen.h"


// 避免循环引用
#pragma mark - 避免循环引用
#define weakify(var) __weak typeof(var) CJWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = CJWeak_##var; \
_Pragma("clang diagnostic pop")

#define WEAKSELF     __weak typeof(self) weakSelf = self;
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define VIEW_BACKCOLOR  self.view.backgroundColor = [UIColor whiteColor];

#define RGBA(r, g, b, a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNavBarHeight self.navigationController.navigationBar.frame.size.height


#define kTopHeight (kStatusBarHeight + kNavBarHeight)



#pragma mark - 屏幕尺寸
#define kIphone4        ([[UIScreen mainScreen] bounds].size.height == 480.f)
#define kIphone5        ([[UIScreen mainScreen] bounds].size.height == 568.f)
#define kIphone6        ([[UIScreen mainScreen] bounds].size.height == 667.f)
#define kIphone6p       ([[UIScreen mainScreen] bounds].size.height == 736.f)
#define kIphoneX        ([[UIScreen mainScreen] bounds].size.height == 812.f)





#define kDengSuccess               @"kDengSuccess"
#define AntJpushRegistrationId     @"AntJpushRegistrationId"

#define kUserDefaults       [NSUserDefaults standardUserDefaults]

#define AntPeopleWeChatAppID @"wx14aa2b1709248742"//微信key
#define AntPeopleGaoDeMapAppID @"fc64df2137353749abbe34feddc7c7c9"//高德地图key




#define AntPeopleBeginOrder @"AntPeopleBeginOrder"



#define chkNumber(oNbr)      ([oNbr isKindOfClass:[NSNumber class]])
#define chkString(oStr)      ([oStr isKindOfClass:[NSString class]])
#define stdNumber(oNbr)      (chkNumber(oNbr) ? oNbr : @0)
#define stdString(oStr)      (chkString(oStr) ? oStr : @"")


#endif /* allHeader_h */
