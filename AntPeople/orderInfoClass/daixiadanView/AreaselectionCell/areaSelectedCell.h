//
//  areaSelectedCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/5/9.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol addressSelecteDelegate <NSObject>

- (void)showAddressSelected:(NSIndexPath *)indexPath;

@end


@interface areaSelectedCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *addressBgView;
@property (strong, nonatomic) IBOutlet UIView *addressSelectedView;
@property (strong, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak,nonatomic) id<addressSelecteDelegate>delegate;

- (void)setIndexPath:(NSIndexPath*)indexpath;

@end
