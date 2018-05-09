//
//  UITextField+fieldFieldPlaceColor.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/16.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#import "UITextField+fieldFieldPlaceColor.h"

@implementation UITextField (fieldFieldPlaceColor)



- (void)phonePlace:(UIFont *)font phoneStr:(NSString *)phoneStr textColor:(UIColor *)color{
    NSAttributedString * attriString = [[NSAttributedString alloc] initWithString:phoneStr attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:font}];
    self.attributedPlaceholder = attriString;
}


@end
