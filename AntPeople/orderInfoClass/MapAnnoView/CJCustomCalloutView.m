//
//  CJCustomCalloutView.m
//  ScrapMaster
//
//  Created by BNT-FS01 on 2017/11/27.
//  Copyright © 2017年 BNT-FS01. All rights reserved.
//

#import "CJCustomCalloutView.h"


@interface CJCustomCalloutView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@end

@implementation CJCustomCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)initSubViews
{
    // 添加标题，即商户名
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"";
    [self addSubview:self.titleLabel];
    
    // 添加副标题，即商户地址
    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin * 2 + kTitleHeight, kCalloutWidth, kCalloutHeight)];
    self.subTitleLabel.font = [UIFont systemFontOfSize:12];
    self.subTitleLabel.numberOfLines = 0;
    self.subTitleLabel.textColor = [UIColor lightGrayColor];
    self.subTitleLabel.text = @"";
    [self addSubview:self.subTitleLabel];
    
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle
{
    self.subTitleLabel.text = subTitle;
    CGSize subSize = [networkTool sizeOfString:subTitle limitSize:CGSizeMake(kTitleWidth, 100.f) fontSize:12.f];
    self.subTitleLabel.frame = CGRectMake(kPortraitMargin, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, subSize.height);
    CGRect aFrame = self.frame;
    CGFloat offsetY = ((subSize.height - 20.f) > 0)?(subSize.height - 20.f):0;
    self.frame = CGRectMake(aFrame.origin.x, -kCalloutHeight - offsetY, kCalloutWidth, kCalloutHeight + offsetY);
}

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.8f].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
