//
//  LoginViewController.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/15.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#import "LoginViewController.h"
#import "mainViewController.h"
#import <MJExtension/MJExtension.h>
#import "webViewController.h"
#import "btRefreshUserModel.h"
#import "resultModel.h"
#import <JPUSHService.h>
#import "GxqAlertView.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (nonatomic,weak) UIColor * fieldColor;
@property (weak, nonatomic) IBOutlet UITextField *phonefield;
@property (weak, nonatomic) IBOutlet UITextField *codeNum;
@property (weak, nonatomic) IBOutlet UIButton *getCodeNumBtn;

@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *phoneNumBgview;
@property (weak, nonatomic) IBOutlet UIView *codeNumBgview;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic,strong) infoModel * infomodel;
@property (nonatomic,strong) NSTimer * getCodeNum;
@property (weak, nonatomic) IBOutlet UILabel *daoJiShiLabel;//倒计时label
@property (nonatomic,unsafe_unretained) long timeIndex;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceTop;
@property (weak, nonatomic) IBOutlet UILabel *kefuNum;

@end

@implementation LoginViewController
{
    NSString *_codeNumStr;
}



- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}



- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[networkTool colorWithHexString:@"#CCCCCC"] size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeName:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [BtAccountTool cleanBtAccount];
    [btRefreshUserModel endBreath];
    if (@available(iOS 11.0, *)) {
    } else {
        self.topConstraint.constant = 134.f;
        self.distanceTop.constant = kStatusBarHeight;
    }
    if (kIphone5) {
        self.codeNum.font = [UIFont systemFontOfSize:12];
        self.phonefield.font = [UIFont systemFontOfSize:12];
    }
    VIEW_BACKCOLOR
    self.navigationItem.title = @"登录";
    _daoJiShiLabel.hidden = YES;
    _phonefield.delegate = self;
    _codeNum.delegate = self;
    _timeIndex = 60;
    [_loginBtn btnAttribute:_loginBtn cornerRadius:5];
    [_getCodeNumBtn imagv:_getCodeNumBtn cornerRadius:3 boardsWidth:0.5 boardColor:[UIColor colorWithRed:253/255.0 green:226/255.0 blue:42/255.0 alpha:1.0]];
     self.loginBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);
    self.daoJiShiLabel.layer.cornerRadius = 2;
    self.daoJiShiLabel.layer.masksToBounds = YES;
    [self changeMessageText];
    _messageLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
    [_messageLabel addGestureRecognizer:tapGesture];
    if (kIphone5||kIphone6||kIphoneX||kIphone6p) {
        _kefuNum.hidden = NO;
    }else{
        _kefuNum.hidden = YES;
    }
    _kefuNum.userInteractionEnabled = YES;
    UITapGestureRecognizer * phoneGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePhoneAction:)];
    [_kefuNum addGestureRecognizer:phoneGesture];
}

- (void)gestureAction:(UITapGestureRecognizer *)gesture{
    webViewController * web = [[webViewController alloc] init];
    [self presentViewController:web animated:YES completion:nil];
}

- (void)gesturePhoneAction:(UITapGestureRecognizer *)gesture{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://0579-87220619"]]];
}

- (void)changeMessageText{
    _messageLabel.attributedText = [self attrWithString:_messageLabel.text];
    _kefuNum.attributedText = [self attrWithStringPhone:_kefuNum.text];
    if (kIphone5) {
        _messageLabel.font = [UIFont systemFontOfSize:10.f];
    }
}

- (NSAttributedString *)attrWithString:(NSString *)string
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{NSForegroundColorAttributeName:[networkTool colorWithHexString:@"#F0CA0E"]} range:[string rangeOfString:@"《回收人用户协议及隐私专项条款》"]];
    return attrString;
}

- (NSAttributedString *)attrWithStringPhone:(NSString *)stringphone
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:stringphone];
    [attrString addAttributes:@{NSForegroundColorAttributeName:[networkTool colorWithHexString:@"#F0CA0E"]} range:[stringphone rangeOfString:@"0579-87220619"]];
    return attrString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)phoneNumAction:(UITextField *)sender {
    if (sender.text.length >= 11) {
        sender.text = [sender.text substringToIndex:11];
    }
}

#pragma textField代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.frame = CGRectMake(0, -50, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)textDidChangeName:(NSNotification *)noti{
    if (_phonefield.text.length > 11) {
        _phonefield.text = [_phonefield.text substringToIndex:11];
        return;
    }
    if (_codeNum.text.length > 4) {
        _codeNum.text = [_codeNum.text substringToIndex:4];
        return;
    }
}



- (IBAction)codeNumAction:(UITextField *)sender {

}



- (IBAction)getCodeNum:(UIButton *)sender {
    if (_phonefield.text.length < 1) {
        [self showAlertTitle:@"提示" message:@"请输入手机号"];
        return;
    }
    if (_phonefield.text.length < 11) {
        [self showAlertTitle:@"提示" message:@"请输入正确的手机号"];
        return;
    }
    [SVProgressHUD show];
    NSDictionary * jsonDic = @{@"json":@{@"mobile":_phonefield.text}};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];//转化为json字符串
    NSDictionary * codeDic = @{@"call":@"103",
                               @"json":jsonStr};
    [[NetWorking shareNet] PostWithURL:SERVER_KEY parameters:codeDic success:^(NSDictionary *dataDict) {//请求验证码接口
        [SVProgressHUD dismiss];
        if ([dataDict[@"state"] integerValue] == 1) {
            [self getTheVerficationCode];
            NSLog(@"code info %@", dataDict);
            
            
#ifdef DEBUG
            _codeNumStr = [NSString stringWithFormat:@"%@",dataDict[@"info"]];
             _codeNum.text = _codeNumStr;
#else
    #if TestRelease
    #else
            _codeNumStr = [NSString stringWithFormat:@"%@",dataDict[@"info"]];
            _codeNum.text = _codeNumStr;
    #endif
#endif
//            if ([_phonefield.text isEqualToString:@"15199999999"]) {
//            }else{
//
//            }
        }else{
            [SVProgressHUD showErrorWithStatus:dataDict[@"errorMsg"]];
        }
       
    } fail:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
    }];
}


- (IBAction)LoginAction:(UIButton *)sender {
    [self.view endEditing:YES];
    UIButton * btn = sender;
    if (btn.tag == 1000) {
        if (_phonefield.text.length < 1) {
            [self showAlertTitle:@"提示" message:@"请输入手机号"];
            return;
        }
        if (_codeNum.text.length < 1) {
            [self showAlertTitle:@"提示" message:@"请输入验证码"];
            return;
        }
        
        if (_codeNum.text.length < 4) {
            [self showAlertTitle:@"提示" message:@"请输入正确的验证码"];
            return;
        }
        [self loadCodeNet];
    }
}

/**
 * 请求登录界面接口
 ***/
- (void)loadCodeNet{
    [SVProgressHUD show];
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//获取设备唯一标识符
    NSDictionary * jsonDic = @{@"json":@{@"mobile":_phonefield.text,
                                         @"code"  :_codeNum.text,
                                         @"pass"  :deviceUUID,
                                         @"type"  :@"1"
                                         }};
   NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];//转化为json字符串格式
    NSDictionary * loginDic = @{@"call":@"102",
                                @"json":jsonStr};
    [[NetWorking shareNet] netRequestParameter:loginDic success:^(id  _Nonnull json) {
        NSLog(@"%@",json);
        
        if ([json[@"state"] integerValue] == 1) {
            [self postUrlToJpush];
            //开始呼吸
            [btRefreshUserModel startBreathe];
            [SVProgressHUD dismiss];
            BtAccount * btacount =  [BtAccount accountWithDict:json[@"info"]];
            [BtAccountTool saveAccount:btacount];
            [BtPushManagerTool recordPushStatus:btacount.status];
            [kUserDefaults setBool:YES forKey:kDengSuccess];
            mainViewController * ov = [[mainViewController alloc] init];
            [[UIApplication sharedApplication] keyWindow].rootViewController = [[UINavigationController alloc] initWithRootViewController:ov];
            BtAccount *account = [BtAccountTool account];
            if ([account.status isEqualToNumber:@0] || [account.status isEqualToNumber:@10]) {
                if ([kUserDefaults boolForKey:AntPeopleBeginOrder]) {
                    [BtPushManagerTool showInfoViewFromStatus:@10 observer:ov animate:NO];
                }
            } else {
                [BtPushManagerTool checkUserCurrentStatus:ov animate:NO];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:json[@"errorMsg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
    }];
}



- (void)postUrlToJpush{
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (registrationID) {
            NSLog(@"JPush Set registrationID Success. %@", registrationID);
            NSString *regiStr = stdString(registrationID);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setValue:regiStr forKey:AntJpushRegistrationId];
            [ud synchronize];
            NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
            jsonDict[@"loginSource"] = @"1";
            jsonDict[@"registrationId"] = regiStr;
#ifdef DEBUG
            jsonDict[@"loginCertEnv"] = @"dev";
#else
            jsonDict[@"loginCertEnv"] = @"prod";
#endif
            NSString * jsonStr = [NetWorking returnJson:jsonDict];
            NSDictionary * paraDic = @{@"call":@"110",
                                       @"json":jsonStr};
            [[NetWorking shareNet] netRequestParameter:paraDic success:^(id  _Nonnull json) {
                NSLog(@"%@",json);
            } failure:^(NSError * _Nonnull error) {
                
            }];
        }
    }];
}


- (void)getTheVerficationCode{
    NSString * string = @"等待(60s)";
    _daoJiShiLabel.text = string;
    _getCodeNumBtn.hidden = YES;
    _daoJiShiLabel.hidden = NO;
    [self startTimer];
}



- (void)startTimer{
    if (!_getCodeNum) {
        _getCodeNum = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(timerAction:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}


- (void)timerAction:(NSTimer *)timer{
    _timeIndex--;
    NSString * string = [NSString stringWithFormat:@"等待(%lds)",_timeIndex];
    _daoJiShiLabel.text = string;
    if (_timeIndex == 0) {
        [self stopTimer];
    }
}


- (void)stopTimer{
    _timeIndex = 60;
    _getCodeNumBtn.hidden = NO;
    _daoJiShiLabel.hidden = YES;
    if (_getCodeNum) {
        [_getCodeNum invalidate];
        _getCodeNum = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        _bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

@end
