//
//  userSelectedCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/5/9.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userSelectedCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic,strong) NSArray * countryArr;


- (void)setCountryArr:(NSArray *)countryArr indexPath:(NSIndexPath *)indexPath;

@end
