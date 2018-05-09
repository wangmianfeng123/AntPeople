//
//  CJCustomCalloutView.h
//  ScrapMaster
//
//  Created by BNT-FS01 on 2017/11/27.
//  Copyright © 2017年 BNT-FS01. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCalloutWidth       200.0
#define kCalloutHeight      70.0

#define kArrorHeight        10.f

#define kPortraitMargin     5.f
#define kPortraitWidth      70.f
#define kPortraitHeight     50.f

#define kTitleWidth         190.f
#define kTitleHeight        20.f


@interface CJCustomCalloutView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;


@end
