//
//  CJCustomPinAnnotationView.h
//  ScrapMaster
//
//  Created by BNT-FS01 on 2017/11/27.
//  Copyright © 2017年 BNT-FS01. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CJCustomCalloutView.h"

typedef void(^CJCustomAnnoBlock)(NSString *addrStr, CGFloat lat, CGFloat lon);

@interface CJCustomPinAnnotationView : MAPinAnnotationView

@property (nonatomic, copy) CJCustomAnnoBlock customAnnoBlock;

@property (nonatomic, readonly) CJCustomCalloutView *calloutView;

@end
