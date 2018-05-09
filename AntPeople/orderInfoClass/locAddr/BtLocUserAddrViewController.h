//
//  BtLocUserAddrViewController.h
//  ScrapMaster
//
//  Created by BNT-FS01 on 2017/12/8.
//  Copyright © 2017年 BNT-FS01. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BtLocUserAddrBlock)(NSString *addrStr, CGFloat latitude, CGFloat longitude);

@interface BtLocUserAddrViewController : UIViewController

@property (nonatomic, copy) BtLocUserAddrBlock locUserAddrBlock;

@end
