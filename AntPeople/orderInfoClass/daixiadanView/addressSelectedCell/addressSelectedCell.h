//
//  addressSelectedCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol addressSelectedDelegate <NSObject>

- (void)selectedAction;

@end

@interface addressSelectedCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *addressBtn;
@property (strong, nonatomic) IBOutlet UILabel *addressSelectedLabel;

@property (weak,nonatomic) id<addressSelectedDelegate>delegate;

@end
