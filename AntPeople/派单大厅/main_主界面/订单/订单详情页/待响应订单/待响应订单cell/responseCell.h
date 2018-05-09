//
//  responseCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol responseDelegate <NSObject>

- (void)responseMapView;

@end



@interface responseCell : UITableViewCell


@property (nonatomic,weak) id<responseDelegate>delegate;

@end
