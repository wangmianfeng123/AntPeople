//
//  waittingResponseCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "infoDetailModel.h"

@interface waittingResponseCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;


- (void)setInfoDetailModel:(infoDetailModel *)infodetail indexPath:(NSIndexPath *)indexPath;

@end
