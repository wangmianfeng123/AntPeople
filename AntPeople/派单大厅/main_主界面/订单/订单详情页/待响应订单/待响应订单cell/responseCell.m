//
//  responseCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "responseCell.h"

@implementation responseCell

- (void)awakeFromNib {
    [super awakeFromNib];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}



- (IBAction)responseBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(responseMapView)]) {
        [self.delegate responseMapView];
    }
}

@end
