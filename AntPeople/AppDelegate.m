//
//  AppDelegate.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/15.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#import "AppDelegate.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ZWIntroductionViewController.h"
#import "LoginViewController.h"
#import "mainViewController.h"
#import <JPUSHService.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <AudioToolbox/AudioToolbox.h>
#import "GxqAlertView.h"
#import "customUpdateView.h"
#import "AVplayerManager.h"
#import "btRefreshUserModel.h"
#import <WXApi.h>

static NSString * appkey = @"93d59acf031d3630b19cbcd0";//极光appkey
static NSString * chanel = @"App Store";
@interface AppDelegate ()<JPUSHRegisterDelegate,WXApiDelegate>
@property (nonatomic,strong) resultModel * resultModel;
@property(nonatomic,strong)ZWIntroductionViewController * introductionView;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:1.f];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
     self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self jpushAPNsinit];
    [self jpushPushinit:launchOptions];
    // 微信注册
    [WXApi registerApp:AntPeopleWeChatAppID];
    [AMapServices sharedServices].apiKey = AntPeopleGaoDeMapAppID;
    if (![kUserDefaults objectForKey:@"fengzi1"]) {
        [self createIntroductionView];
    }else{
        [self postNetWorkingToUrl];
    }
    [self netWorkCheckingConfiguration];
    //版本更新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self updateNewVersion];
    });
    return YES;
}


- (void)firstlogin{
    [self enterAntPeople:YES];
}


- (void)createIntroductionView{
    NSArray *coverImageNames = @[@"clear", @"clear",@"clear"];
    NSArray *backgroundImageNames;
    if (kIphone5 || kIphone6) {
         backgroundImageNames = @[@"guide_01",@"guide_02",@"guide_03"];
    }else if (kIphone6p){
        backgroundImageNames = @[@"guide_01_01_01",@"guide_02_02_02",@"guide_03_03_03"];
    }else if (kIphoneX){
         backgroundImageNames = @[@"guide_01_01",@"guide_02_02",@"guide_03_03"];
    }else{
          backgroundImageNames = @[@"guide_01",@"guide_02",@"guide_03"];
    }
    self.introductionView = [[ZWIntroductionViewController alloc] initWithCoverImageNames:coverImageNames backgroundImageNames:backgroundImageNames];
    __block AppDelegate * weakSelf = self;
    self.introductionView.didSelectedEnter = ^{
        [weakSelf enterAntPeople:YES];
        weakSelf.introductionView = nil;
    };
    self.window.rootViewController = self.introductionView;
    [kUserDefaults setObject:@"wang" forKey:@"fengzi1"];
}


- (void)updateNewVersion{//检查版本更新
    customUpdateView * custom = [customUpdateView customUpdateView];
    [custom checkVersion];
}


- (void)postNetWorkingToUrl{
   
    BtAccount * bt = [BtAccountTool account];
    if (bt) {
        resultModel * model = [resultModel mj_objectWithKeyValues:bt];
        NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//获取设备唯一标识符
        NSDictionary * jsonDic = @{@"json":@{@"mobile":model.mobile,
                                             @"pass"  :deviceUUID}};
        NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];//转化为json字符串格式
        NSDictionary * loginDic = @{@"call":@"102",
                                    @"json":jsonStr};
        [[NetWorking shareNet] netRequestParameter:loginDic success:^(id  _Nonnull json) {
            if ([json[@"state"] integerValue] == 1) {
                BtAccount * btacount =  [BtAccount accountWithDict:json[@"info"]];
                [BtAccountTool saveAccount:btacount];
                [BtPushManagerTool recordPushStatus:btacount.status];
                _resultModel = [resultModel new];
                _resultModel = [resultModel mj_objectWithKeyValues:btacount];
                [self firstlogin];
            }else{
                LoginViewController * loginVC = [[LoginViewController alloc]init];
                [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
            }
        } failure:^(NSError * _Nonnull error) {
            LoginViewController * loginVC = [[LoginViewController alloc]init];
            [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
        }];
    }else{
        LoginViewController * loginVC = [[LoginViewController alloc]init];
        [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
    }
}

- (void)enterAntPeople:(BOOL)enterAnt{
    if ([kUserDefaults objectForKey:kDengSuccess]) {
        //设置标签名
        NSSet * set = [[NSSet alloc] initWithObjects:@"PEDLAR", nil];
        [JPUSHService setTags:set completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        } seq:0];
        //设置别名
        NSString * aliseStr = [NSString stringWithFormat:@"PEDLAR_%ld",(long)_resultModel.ID];
        [JPUSHService setAlias:aliseStr completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        } seq:0];
        mainViewController * orderT = [[mainViewController alloc] init];
        UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:orderT];
        self.window.rootViewController = navc;
        
        BtAccount *account = [BtAccountTool account];
        if ([account.status isEqualToNumber:@0] || [account.status isEqualToNumber:@10]) {
            if ([kUserDefaults boolForKey:AntPeopleBeginOrder]) {
                [BtPushManagerTool showInfoViewFromStatus:@10 observer:navc animate:NO];
            }
        } else {
            [BtPushManagerTool checkUserCurrentStatus:navc animate:NO];
        }
    }else{
        LoginViewController * login = [[LoginViewController alloc] init];
        [UIApplication sharedApplication].keyWindow.rootViewController = login;
    }
    [self.window makeKeyAndVisible];
}


- (void)wifi
{
    if ([[kUserDefaults objectForKey:kDengSuccess] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wifi_" object:nil userInfo:nil];
    }
}

#pragma mark - 网络监听 检测
- (void)netWorkCheckingConfiguration{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]
     setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         switch (status) {
             case AFNetworkReachabilityStatusNotReachable:
                 [self wifi];
                 break;
             case AFNetworkReachabilityStatusReachableViaWiFi:
             case AFNetworkReachabilityStatusReachableViaWWAN:
                 break;
             default:
                 break;
         }
     }];
}


#pragma mark - WeChatDelegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}


- (void)onReq:(BaseReq *)req
{
    
}


- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        // 支付返回
//        PayResp *response = (PayResp *)resp;
    } else {
        SendMessageToWXResp *sendResp = (SendMessageToWXResp *)resp;
        NSString *shareResp = @"分享成功";
        if (sendResp.errCode == 0) {
            // 分享成功
            shareResp = @"分享成功";
        } else if (sendResp.errCode == -2) {
            // 已取消分享
            shareResp = @"已取消分享";
        } else {
            //  分享失败
            shareResp = @"分享失败";
        }
        [SVProgressHUD showInfoWithStatus:shareResp];
    }
}



- (void)jpushAPNsinit{
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
}

- (void)jpushPushinit:(NSDictionary *)launchOptions{
    [JPUSHService setupWithOption:launchOptions appKey:appkey channel:chanel apsForProduction:YES advertisingIdentifier:nil];
}

//注册成功并上报devicetoken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //注册devicetoken
    [JPUSHService registerDeviceToken:deviceToken];
}

//实现注册APNS失败接口
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"did Fail To Register For Remote Notifications with error:%@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (@available(iOS 11.0, *)) {
         [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    } else {
         [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    [BtAccount silenceLoginAntPeople];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma JPUSHRegisDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSString * sound_Str = @"bt_sounds";
    if ([userInfo[@"msgCall"] isEqualToString:@"200"]) {
        [[AVplayerManager shareSoundPlayerManager] play_musicWithStr:sound_Str];
    }
    [BtPushManagerTool setPushInfoWithDict:userInfo isBreath:NO];
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    }//需要执行这个方法，提醒用户有badge
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [BtPushManagerTool setPushInfoWithDict:userInfo isBreath:NO];
    if (@available(iOS 10.0, *)) {
        if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }
    } else {
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    [BtPushManagerTool setPushInfoWithDict:userInfo isBreath:NO];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    [BtPushManagerTool setPushInfoWithDict:userInfo isBreath:NO];
}

@end
