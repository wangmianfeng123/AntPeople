//
//  phoneNumField.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/16.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#import "phoneNumField.h"

@implementation phoneNumField


- (instancetype)initWithFrame:(CGRect)frame{
    if (self) {
        self = [super initWithFrame:frame];
        UIFont * font = [UIFont systemFontOfSize:15];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入手机" attributes:
                                          @{NSForegroundColorAttributeName:[UIColor redColor],
                                            NSFontAttributeName:font
                                            }];
        self.attributedPlaceholder = attrString;
    }
    return self;
}






@end
