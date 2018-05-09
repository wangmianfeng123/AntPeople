//
//  headerView.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/25.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "headerView.h"
#import <Masonry.h>

@interface headerView()

@property (nonatomic, strong)UIView *backView;

@property (nonatomic, strong)UIButton *arrowButton;

@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation headerView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self headerView];
    }
    
    return self;
}


- (void)setDict:(NSMutableDictionary *)dict{
    _dict = dict;
    NSString * string = [NSString stringWithFormat:@"%ld",(long)_headSection];
    if ([[_dict valueForKey:string] isEqualToString:@"0"]) {
        [_arrowButton setSelected:NO];
    }else{
        [_arrowButton setSelected:YES];
    }
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}


- (void)headerView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        _backView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 0, SCREEN_WIDTH, 60)];
        _backView.userInteractionEnabled = YES;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowButton addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:_arrowButton];
        [_arrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-21);
            make.width.height.mas_equalTo(15);
            make.top.mas_equalTo(self.backView.mas_top).offset(30-(15/2));
        }];
        [_arrowButton setBackgroundImage:[UIImage imageNamed:@"收起"] forState:UIControlStateNormal];
        [_arrowButton setBackgroundImage:[UIImage imageNamed:@"展开"] forState:UIControlStateSelected];

        UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
        [_backView addGestureRecognizer:gesture];
        NSLog(@"aaa 22222222");
        [_backView addSubview:_titleLabel];
        [self.contentView addSubview:_backView];
    }
}


- (void)setHeadSection:(NSInteger)headSection
{
    _headSection = headSection;
    if (headSection == 0) {
        _titleLabel.text = @"选择已有用户";
    }else{
        _titleLabel.text = @"新增用户信息";
    }
    
}


- (void)iconAction:(UIButton *)btn {
    NSLog(@" aaa 点击按钮 %ld", (long)self.headSection);
    [self.arrowButton setSelected:!self.arrowButton.isSelected];
    if ([self.delegate respondsToSelector:@selector(iconBtnSelected:)]) {
        [self.delegate iconBtnSelected:self.headSection];
    }
}
- (void)gestureAction:(UITapGestureRecognizer *)gesture
{
//    NSLog(@"点击头部视图");
    NSLog(@" aaa 点击按钮 %ld", (long)self.headSection);
    [self.arrowButton setSelected:!self.arrowButton.isSelected];
    if ([self.delegate respondsToSelector:@selector(iconBtnSelected:)]) {
        [self.delegate iconBtnSelected:self.headSection];
    }
}





@end
