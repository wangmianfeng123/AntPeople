//
//  selectedAddressView.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/5/9.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "selectedAddressView.h"
#import "userSelectedCell.h"


@interface selectedAddressView ()<UITableViewDelegate,UITableViewDataSource>

@end


@implementation selectedAddressView


- (void)awakeFromNib{
    [super awakeFromNib];
    _allBgView.layer.cornerRadius = 4;
    _allBgView.layer.borderWidth = .5f;
    _allBgView.layer.borderColor = [networkTool colorWithHexString:@"#666666"].CGColor;
    _allBgView.layer.masksToBounds = YES;
    _selectedView.delegate = self;
    _selectedView.dataSource = self;
    _selectedView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_selectedView registerNib:[UINib nibWithNibName:@"userSelectedCell" bundle:nil] forCellReuseIdentifier:@"cellId"];
//    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getureAction:)];
//    [self addGestureRecognizer:gesture];
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAc:)];
    _topView.userInteractionEnabled = YES;
    [_topView addGestureRecognizer:gesture];
}


- (void)gestureAc:(UITapGestureRecognizer *)gesture{
    [self removeFromSuperview];
}


- (void)getureAction:(UITapGestureRecognizer *)gesture{
//    if ([self.delegate respondsToSelector:@selector(selfViewDiss)]) {
//        [self.delegate selfViewDiss];
//    }
}


- (void)setCountryArr:(NSArray *)countryArr{
    _countryArr = countryArr;

}



- (void)setDistanceTop:(NSLayoutConstraint *)distanceTop{
    _distanceTop = distanceTop;
}

+(instancetype)selectedAddressView{
     return [[[NSBundle mainBundle]loadNibNamed:@"selectedAddressView" owner:self options:nil]lastObject];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _countryArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    userSelectedCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    [cell setCountryArr:_countryArr indexPath:indexPath];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = _countryArr[indexPath.row];
    NSString * cityCode = stdString(dic[@"city_code"]);
    self.cityName = stdString(dic[@"city_name"]);
    self.block(self.cityName,cityCode);
    [self removeFromSuperview];
    
}





@end
