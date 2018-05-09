//
//  headerView.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/25.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol headerActionDelegate <NSObject>

- (void)iconBtnSelected:(NSInteger)index;



@end


@interface headerView : UITableViewHeaderFooterView

@property (nonatomic,weak)id<headerActionDelegate>delegate;

@property (nonatomic, assign) NSInteger headSection;

@property (nonatomic,strong) NSMutableDictionary * dict;

//+(UIView *)headerView;



@end
