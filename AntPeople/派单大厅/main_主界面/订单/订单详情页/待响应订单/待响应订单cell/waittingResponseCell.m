//
//  waittingResponseCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "waittingResponseCell.h"


@implementation waittingResponseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setInfoDetailModel:(infoDetailModel *)infodetail indexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSLog(@"infoModel:%@",infodetail.supplier.mobile);
        self.leftLabel.text = @"电话";
        self.rightLabel.text = stdString(infodetail.supplier.mobile);
    }else if (indexPath.row == 1){
        self.leftLabel.text = @"时间";//_infoDetailModel.create_time
        self.rightLabel.text = stdString([networkTool UTCchangeDate:infodetail.create_time]);
    }else if (indexPath.row == 2){
        self.leftLabel.text = @"地址";
        self.rightLabel.text = stdString(infodetail.address_details);
    }
}

@end
