//
//  areaSelectedCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/5/9.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "areaSelectedCell.h"




@interface areaSelectedCell ()

@property (nonatomic,strong) NSIndexPath * indexPath;

@end

@implementation areaSelectedCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.addressSelectedView.layer.cornerRadius = 5.0f;
    self.addressSelectedView.layer.borderWidth = .5f;
    self.addressSelectedView.layer.borderColor = [networkTool colorWithHexString:@"#cccccc"].CGColor;
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
    
    [self.addressBgView addGestureRecognizer:gesture];
}


- (void)setIndexPath:(NSIndexPath *)indexpath{
    _indexPath = indexpath;
}


- (void)gestureAction:(UITapGestureRecognizer *)gesture{
    NSLog(@"点击啊");
    if ([self.delegate respondsToSelector:@selector(showAddressSelected:)]) {
        [self.delegate showAddressSelected:_indexPath];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
