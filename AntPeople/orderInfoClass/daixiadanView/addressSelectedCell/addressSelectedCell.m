//
//  addressSelectedCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "addressSelectedCell.h"

@implementation addressSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.addressBtn.layer.cornerRadius = 5;
    self.addressBtn.layer.borderColor = [networkTool colorWithHexString:@"#cccccc"].CGColor;
    self.addressBtn.layer.borderWidth = .5f;
}

- (IBAction)addressSelectedBtn:(UIButton *)sender {
    NSLog(@"点击按钮");
    if ([self.delegate respondsToSelector:@selector(selectedAction)]) {
        [self.delegate selectedAction];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    [self.addressBtn setTitleColor:[networkTool colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
//    [self.addressBtn setTitle:@"请选择地址" forState:UIControlStateNormal];
//    [self.addressBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [self.addressBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
}

@end
