//
//  userSelectedCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/5/9.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "userSelectedCell.h"


@interface userSelectedCell ()

{
    NSString * _city_Code;
}


@end



@implementation userSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}



- (void)setCountryArr:(NSArray *)countryArr indexPath:(NSIndexPath *)indexPath{
    _countryArr = countryArr;
    NSDictionary * dic = _countryArr[indexPath.row];
    self.addressLabel.text = [NSString stringWithFormat:@"%@",dic[@"city_name"]];
    _city_Code = stdString(dic[@"city_code"]);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

@end
