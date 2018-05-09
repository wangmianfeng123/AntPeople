//
//  closeOpenTableViewCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/25.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "closeOpenTableViewCell.h"

@implementation closeOpenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"点击选中"] forState:UIControlStateSelected];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setTeamModel:(myTeamModel *)teamModel{
    _teamModel = teamModel;
    self.nameLabel.text = stdString(_teamModel.name);
}



@end
