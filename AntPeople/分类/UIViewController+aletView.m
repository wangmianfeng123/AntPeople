//
//  UIViewController+aletView.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/15.
//  Copyright © 2017年 王绵峰. All rights reserved.
//





#import "UIViewController+aletView.h"

@implementation UIViewController (aletView)


- (void)showAlertTitle:(NSString *)title message:(NSString *)message{
    
    UIAlertController * alert =[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{
    }];
    
}


@end
