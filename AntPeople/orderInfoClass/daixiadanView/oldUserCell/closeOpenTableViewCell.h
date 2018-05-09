//
//  closeOpenTableViewCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/25.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myTeamModel.h"

@interface closeOpenTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *selectedBtn;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong,nonatomic)myTeamModel * teamModel;

@end
