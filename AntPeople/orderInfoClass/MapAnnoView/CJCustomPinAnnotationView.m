//
//  CJCustomPinAnnotationView.m
//  ScrapMaster
//
//  Created by BNT-FS01 on 2017/11/27.
//  Copyright © 2017年 BNT-FS01. All rights reserved.
//

#import "CJCustomPinAnnotationView.h"


@interface CJCustomPinAnnotationView ()

@property (nonatomic, strong, readwrite) CJCustomCalloutView *calloutView;

@end

@implementation CJCustomPinAnnotationView


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil)
        {
            self.calloutView = [[CJCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x, -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        self.calloutView.title = self.annotation.title;
        self.calloutView.subTitle = self.annotation.subtitle;
        
        [self addSubview:self.calloutView];
        
        if (self.customAnnoBlock) {
            self.customAnnoBlock(self.annotation.subtitle, self.annotation.coordinate.latitude, self.annotation.coordinate.longitude);
            NSLog(@"----- 1 %f  %f", self.annotation.coordinate.latitude, self.annotation.coordinate.longitude);
        }
        
    } else {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

@end
