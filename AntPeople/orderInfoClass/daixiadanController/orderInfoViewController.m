//
//  orderInfoViewController.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/23.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "orderInfoViewController.h"
#import "closeOpenTableViewCell.h"
#import "newUserTableViewCell.h"
#import "userOrderThreeTableViewCell.h"
#import "CollectionTableViewCell.h"
#import "paperCollectionView.h"
#import "CollectionViewCell.h"
#import "fourthTableViewCell.h"
#import "OnePaperTableViewCell.h"
#import "threeTableViewCell.h"
#import "addressSelectedCell.h"
#import "BtLocUserAddrViewController.h"
#import "tradingDataController.h"
#import "generationOrder.h"
#import "areaSelectedCell.h"
#import "selectedAddressView.h"
#import "headerView.h"
#import "GxqAlertView.h"


static NSString * CELLID = @"CELLID";
static NSString * NEWCELLID = @"NEWCELLID";
static NSString * USERORDERTHREEID = @"USERORDERTHREEID";
static NSString * FOURTHID = @"FOURTHID";
static NSString * ONEPAPERID = @"ONEPAPERID";
static NSString * COLLECTIONCELL = @"COLLECTIONCELL";
static NSString * THREECELLID = @"THREECELLID";
static NSString * ADDRESSCELLID = @"ADDRESSCELLID";
static NSString * AREASELECTEDID = @"AREASELECTEDID";
static NSString * cellName = @"closeOpenTableViewCell";
static NSString * newUserCell = @"newUserTableViewCell";
static NSString * userOrderThreeCell = @"userOrderThreeTableViewCell";
static NSString * CollectionViewNewCell = @"CollectionTableViewCell";
static NSString * fourthCell = @"fourthTableViewCell";
static NSString * onePaper = @"OnePaperTableViewCell";
static NSString * threeCell = @"threeTableViewCell";
static NSString * addressCell = @"addressSelectedCell";
static NSString * areaCell = @"areaSelectedCell";

//30207获取未完成订单数量
@interface orderInfoViewController ()<UITableViewDelegate,UITableViewDataSource,headerActionDelegate,UICollectionViewDelegate,UICollectionViewDataSource,btnActionDelegate,addressSelectedDelegate,keyBoardDelegate,threeCollectionDelegate,UITextFieldDelegate,fourthDelegate,addressSelecteDelegate,selectedAddressViewDelegate>
{
    NSMutableDictionary *_dict;
    NSIndexPath * _currentIndexPath;
    NSString *_AuserID;
    NSString *_addressStr;
    NSString * _cityName;//存放县的名字
    NSString *_cityCode;
    UITextField *_nameTextField;
    UITextField *_phoneTextField;
    UITextField *_singlePriceTextField;
    UITextField *_weighttextField;
    UITextField *_youhuiTextField;
    NSMutableDictionary *_allDict;//存放输入框里的内容
    UILabel *_systemMoneyLabel;
    UILabel *_requireFenLabel;
//    UILabel * _city_nameLabel;
    UIView *_slectedBgView;
    CGFloat _lat;
    CGFloat _lng;
    NSInteger _btnSelectedIndex;
    NSString *_newUserID;
    
    NSString * _firstSectionStr;
    NSString *_secondSectionStr;
    
    UIView *_selectedBgView;
    selectedAddressView *_addressView;
}

@property (strong, nonatomic) IBOutlet UITableView *closeOpenTableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *distanceTop;

@property (strong, nonatomic)paperCollectionView * collectionView;

@property (strong,nonatomic)NSMutableArray * categoryNameArr;//存储货品类型数组
@property (strong,nonatomic)NSMutableArray * categoryIdArr;//存储货物ID数组

@property (strong,nonatomic) NSMutableArray * countryLelveArr;//存放县数组

@property (strong,nonatomic) NSArray * AuserMarr;

@property (strong,nonatomic) UILabel * city_nameLabel;

@property (strong,nonatomic) NSMutableArray * btnArr;


@end

@implementation orderInfoViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeName:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstSectionStr = @"sectionClose";
    [kUserDefaults removeObjectForKey:@"requireInteral"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"代下单";
    if (@available(iOS 11.0, *)) {
    } else {
        self.distanceTop.constant = 64;
    }
    
    
    [BtPushManagerTool sharedPushManager].observerPushInfoBlock = ^(BtPushInfoModel * _Nonnull pushInfo, NSNumber * _Nonnull userStatus, NSInteger refresh) {
         [BtPushManagerTool checkUserCurrentStatus:self animate:YES];
        if (!refresh) {
        }
    };
    
    _dict = [NSMutableDictionary dictionary];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_normal_icon"] action:@selector(backToRightAction:)];
     [self.navigationController.navigationBar shadowWithColor:[UIColor blackColor] shadowOffSet:CGSizeMake(0, 2) shadowOpacity:0.05];
    [self addRightBarButtonItemWithTitle:@"取消" action:@selector(cancelAction:)];
    
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:CELLID];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:newUserCell bundle:nil] forCellReuseIdentifier:NEWCELLID];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:fourthCell bundle:nil] forCellReuseIdentifier:FOURTHID];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:CollectionViewNewCell bundle:nil] forCellReuseIdentifier:COLLECTIONCELL];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:onePaper bundle:nil] forCellReuseIdentifier:ONEPAPERID];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:threeCell bundle:nil] forCellReuseIdentifier:THREECELLID];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:addressCell bundle:nil] forCellReuseIdentifier:ADDRESSCELLID];
    [self.closeOpenTableView registerNib:[UINib nibWithNibName:areaCell bundle:nil] forCellReuseIdentifier:AREASELECTEDID];
    self.closeOpenTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.closeOpenTableView.delegate = self;
    self.closeOpenTableView.dataSource = self;
    
    [self.closeOpenTableView registerClass:[headerView class] forHeaderFooterViewReuseIdentifier:@"closeOpenHeaderView"];
    
    _categoryNameArr = [[NSMutableArray alloc] init];
    _categoryIdArr = [[NSMutableArray alloc] init];
    _AuserMarr = [[NSArray alloc] init];
    _allDict = [[NSMutableDictionary alloc] init];
    _countryLelveArr = [[NSMutableArray alloc] init];

    [self netPostcategoryName];//请求废品类型
    [self netPostAuser];
    
    //请求行政区划
    [self netDistrution];
}



- (NSMutableArray *)btnArr{
    if (!_btnArr) {
        _btnArr = [NSMutableArray array];
    }
    return _btnArr;
}


- (void)netDistrution{
    
    NSDictionary * jsonDic = @{@"json":@{@"parent_code":@"330784"}};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];
    NSDictionary * dic = @{@"call":@10201,@"json":jsonStr};
     __weak typeof(self)weakSelf = self;
    [generationOrder getCountryLelve:dic success:^(NSArray *countryArr, BOOL status) {
        [weakSelf.countryLelveArr addObjectsFromArray:countryArr];
    } failue:^(NSError *error) {
        
    }];
    
}


- (void)netPostcategoryName{
    NSDictionary * jsonDic = @{@"json":@{}};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];
    NSDictionary * paraDic = @{@"call":@201,@"json":jsonStr};
    __weak typeof(self)weakSelf = self;
    [generationOrder categoryNameDic:paraDic categoryNameBlock:^(NSArray *categoryName, NSArray *categoryId, BOOL status) {
        [weakSelf.categoryNameArr addObjectsFromArray:categoryName];
        [weakSelf.categoryIdArr addObjectsFromArray:categoryId];
         [self.collectionView reloadData];
    } failue:^(NSError *error) {
        
    }];
}



- (void)netPostAuser{//20203
    NSDictionary * json = @{@"json":@{}};
    NSString * jsonStr = [NetWorking returnJson:json[@"json"]];
    NSDictionary * jsonDic = @{@"call":@20203,@"json":jsonStr};
    [generationOrder BindAendUser:jsonDic success:^(NSArray *dictArr, BOOL status) {
        _AuserMarr = dictArr;
    } failue:^(NSError *error) {
        
    }];
    
}

- (paperCollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * flowlayOut = [[UICollectionViewFlowLayout alloc] init];
        [flowlayOut setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowlayOut setMinimumInteritemSpacing:12];
        _collectionView = [[paperCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180) collectionViewLayout:flowlayOut];
        [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"collecCellId"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (void)cancelAction:(UIButton *)btn{
    [GxqAlertView showWithdescText:@"确定取消信息填写？" LeftText:@"取消" rightText:@"确定" LeftBlock:^{
        
    } RightBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)backToRightAction:(UIButton *)btn{
    [GxqAlertView showWithdescText:@"确定取消信息填写？" LeftText:@"取消" rightText:@"确定" LeftBlock:^{
        
    } RightBlock:^{
         [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self.closeOpenTableView endEditing:YES];
}


- (void)iconBtnSelected:(NSInteger)index
{
    NSLog(@"点击按钮");
    [self currentIndex:index];
    [self otherIndex:index];
}



- (void)currentIndex:(NSInteger)index{
    NSInteger indexSlected = index;   
    NSString * stringValue = [NSString stringWithFormat:@"%ld",(long)indexSlected];
    NSInteger value = [[_dict objectForKey:stringValue] integerValue];
        if (value == 0) {
            NSLog(@"打开");
            [_dict setValue:@"1" forKey:stringValue];
            _firstSectionStr = @"sectionOpen";
        }else{
            NSLog(@"关闭");
            [_dict setValue:@"0" forKey:stringValue];
            _firstSectionStr = @"sectionClose";
        }

    NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:index];
    [self.closeOpenTableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}




- (void)otherIndex:(NSInteger)index{
    NSInteger indexSlected = index;
    if (index == 0) {
        NSString * stringValue = [NSString stringWithFormat:@"%ld",(long)indexSlected+1];
        if ([_firstSectionStr isEqualToString:@"sectionOpen"]) {
            [_dict setValue:@"0" forKey:stringValue];
        }
        NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:1];
        [self.closeOpenTableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"第一个section是打开的");
        _secondSectionStr = @"firstOpen";
    }else if (index == 1){
        NSString * stringValue = [NSString stringWithFormat:@"%d",0];
        if ([_firstSectionStr isEqualToString:@"sectionOpen"]) {
            [_dict setValue:@"0" forKey:stringValue];
        }
        NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:0];
        [self.closeOpenTableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
         NSLog(@"第二个section是打开的");
        _secondSectionStr = @"secondOpen";
    }
}


#pragma tableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString * string = [NSString stringWithFormat:@"%ld",(long)section];
    NSInteger currentIndex = [[_dict valueForKey:string] integerValue];
    if (currentIndex == 1) {
        if (section == 0) {
            return _AuserMarr.count;
        }else if (section == 1){
            return 4;
        }
    }
    if (section == 2 || section == 3 || section == 5) {
        return 1;
    }
    if (section == 4) {
        return 2;
    }
    
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 5) {
        return 363;
    }else if(indexPath.section == 3){
        return 200;
    }else if(indexPath.section == 2 || indexPath.section == 4){
        return 80;
    }else{
        return 45;
    }
    return 0;
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0||section == 1) {
        return 60;
    }else{
        return 0.001;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
      return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 200, 1)];
    if (section == 0||section == 1) {
       view.backgroundColor = [networkTool colorWithHexString:@"#eaeaea"];
    }else{
        view.backgroundColor = [UIColor whiteColor];
    }
    return view;
}


//20204

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        headerView *headerV = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"closeOpenHeaderView"];
        headerV.delegate = self;
        headerV.headSection = section;
        headerV.dict = _dict;
        return headerV;
    } else {
        return nil;
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        closeOpenTableViewCell * cell = [tableView cellForRowAtIndexPath:_currentIndexPath];
        cell.selectedBtn.selected = NO;
        
        closeOpenTableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.selectedBtn.selected = YES;
        myTeamModel * teamModel = _AuserMarr[indexPath.row];
        _AuserID = teamModel.ID;
        NSLog(@"A端人员编号:%@",_AuserID);
         _currentIndexPath = indexPath;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    closeOpenTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CELLID];
    newUserTableViewCell * newCell = [tableView dequeueReusableCellWithIdentifier:NEWCELLID];
    fourthTableViewCell * fourthCell = [tableView dequeueReusableCellWithIdentifier:FOURTHID];
    CollectionTableViewCell * collectionCell = [tableView dequeueReusableCellWithIdentifier:COLLECTIONCELL];
    OnePaperTableViewCell * onePaperCell = [tableView dequeueReusableCellWithIdentifier:ONEPAPERID];
    threeTableViewCell * threeCell = [tableView dequeueReusableCellWithIdentifier:THREECELLID];
    addressSelectedCell * addressSelectedCell = [tableView dequeueReusableCellWithIdentifier:ADDRESSCELLID];
    areaSelectedCell * areaSCell = [tableView dequeueReusableCellWithIdentifier:AREASELECTEDID];
    if (indexPath.section == 0) {

        myTeamModel * teamModel = _AuserMarr[indexPath.row];
        [cell setTeamModel:teamModel];
        if (_currentIndexPath == indexPath) {
            cell.selectedBtn.selected = YES;
        }else{
            cell.selectedBtn.selected = NO;
        }
        return cell;
    }else if (indexPath.section == 1){//新增用户信息cell(姓名、电话、地址)
        if (indexPath.row == 0 || indexPath.row == 1) {//姓名和电话输入框
            indexPath.row == 0?(_nameTextField = newCell.rightTextField):(_phoneTextField = newCell.rightTextField);
            _nameTextField.delegate = self;
            _phoneTextField.delegate = self;
            if (_allDict) {
                [self allDict:_allDict];//读取字典里保存的值
            }
            
            newCell.delegate = self;
            newCell.delegate = self;
            [newCell setindexPath:indexPath];
            return newCell;
        }else if (indexPath.row == 2){
            areaSCell.delegate = self;
            _city_nameLabel = areaSCell.areaLabel;
            if (_cityName) {
                _city_nameLabel.text = stdString(_cityName);
            }
            _slectedBgView = areaSCell.addressBgView;
            [areaSCell setIndexPath:indexPath];
            return areaSCell;
        }else{
            addressSelectedCell.delegate = self;
            if (_addressStr) {//地址
                addressSelectedCell.addressSelectedLabel.text = [NSString stringWithFormat:@"%@",_addressStr];
            }
            return addressSelectedCell;
        }
    }else if (indexPath.section == 5){//系统结算金额，所需积分cell
        fourthCell.delegate = self;
        _youhuiTextField = fourthCell.youHuiTextField;//优惠金额输入框
        _youhuiTextField.delegate = self;
        _requireFenLabel = fourthCell.requireIntegralLabel;
        _systemMoneyLabel = fourthCell.systemMoney;
        [self systemRequire:_dict systemLable:fourthCell.systemLabel];//积分
        [self systemMoneyAndrequireDic:_dict systemLable:fourthCell.totalMoneyOriginal];//系统金额
        return fourthCell;
    }else if (indexPath.section == 3){//选择货品类型collection
        [collectionCell.contentView addSubview:self.collectionView];
        return collectionCell;
    }else if (indexPath.section == 2){
        return onePaperCell;
    }else if (indexPath.section == 4){//货物重量和单价输入框
        indexPath.row == 0?(_weighttextField = threeCell.textField):(_singlePriceTextField = threeCell.textField);
        _weighttextField.delegate = self;
        _singlePriceTextField.delegate = self;
        threeCell.delegate = self;
        [self weightAndSinglePriceDict:_allDict];
        threeCell.delegate = self;
        [threeCell setIndexPath:indexPath];
        return threeCell;
    }
    return nil;
}




- (void)allDict:(NSDictionary *)dict{
    if ([dict valueForKey:@"name"]) {
        _nameTextField.text = stdString([dict valueForKey:@"name"]);
    }
    if ([dict valueForKey:@"phone"]) {
        _phoneTextField.text = stdString([dict valueForKey:@"phone"]);
    }
}


- (void)weightAndSinglePriceDict:(NSDictionary *)dict{
    if ([dict valueForKey:@"weight"]) {
        _weighttextField.text = stdString([dict valueForKey:@"weight"]);
    }
    if ([dict valueForKey:@"price"]) {
        _singlePriceTextField.text = stdString([dict valueForKey:@"price"]);
    }
   
}



- (void)systemMoneyAndrequireDic:(NSDictionary *)dic systemLable:(UILabel *)label{
    if ([dic valueForKey:@"amount"]) {
        _systemMoneyLabel.hidden = NO;
        label.hidden = YES;
        _systemMoneyLabel.text = stdString([dic valueForKey:@"amount"]);
    }
    if ([dic valueForKey:@"youhui"]) {
        _youhuiTextField.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"youhui"]];
    }
}


- (void)systemRequire:(NSDictionary *)dic systemLable:(UILabel *)label{
    if ([kUserDefaults valueForKey:@"requireInteral"]) {
        _requireFenLabel.hidden = NO;
        label.hidden = YES;
        _requireFenLabel.text = stdString([kUserDefaults valueForKey:@"requireInteral"]);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SCREEN_WIDTH-60)/3, 40);
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _categoryNameArr.count;
}


/** section的margin*/
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat widthF = 15;
    return UIEdgeInsetsMake(widthF, widthF, widthF,widthF);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collecCellId" forIndexPath:indexPath];
    cell.delegate = self;
    [cell.btnType setTitle:_categoryNameArr[indexPath.row] forState:UIControlStateNormal];
    cell.btnType.tag = [_categoryIdArr[indexPath.row] integerValue];
    for (NSInteger i = 0; i < _categoryNameArr.count; i++) {
        [self.btnArr addObject:cell.btnType];
    }
    return cell;
}



//collectionviewcell代理方法
- (void)itemSelectedBtn:(UIButton *)selectedBtn{
    UIButton * button = (UIButton *)selectedBtn;
    for (NSInteger j = 0; j < self.btnArr.count; j++) {
        UIButton * btn = self.btnArr[j];
        if (button.tag == [self.btnArr[j] tag]) {
            btn.selected = YES;
        }
        btn.selected = NO;
    }
    _btnSelectedIndex = button.tag;
}


- (void)selectedAction{
    [self.view endEditing:YES];
    BtLocUserAddrViewController * locaAddVC = [[BtLocUserAddrViewController alloc] init];
    locaAddVC.locUserAddrBlock = ^(NSString *addrStr, CGFloat latitude, CGFloat longitude) {
        NSLog(@"%@%f%f",addrStr,latitude,longitude);
        _addressStr = addrStr;
        _lat = latitude;
        _lng = longitude;
        [self.closeOpenTableView reloadData];
    };
    [self.navigationController pushViewController:locaAddVC animated:YES];
}



- (void)selfViewDiss{
    [_addressView removeFromSuperview];
}



#pragma selectedaddressDelegate
- (void)showAddressSelected:(NSIndexPath *)indexPath{
    CGRect rectTableView = [self.closeOpenTableView rectForRowAtIndexPath:indexPath];
    CGRect rectInSuperview = [self.closeOpenTableView convertRect:rectTableView toView:[self.closeOpenTableView superview]];
    _addressView = [selectedAddressView selectedAddressView];
    _addressView.delegate = self;
    
    _addressView.countryArr = _countryLelveArr;
    
    __weak typeof(self)weakSelf = self;
    _addressView.block = ^(NSString *str, NSString *city_code) {
        _cityName = str;
        _cityCode = city_code;
        weakSelf.city_nameLabel.text = stdString(str);
    };
   
    _addressView.distanceTop.constant = rectInSuperview.origin.y+7;
    [self.view.window addSubview:_addressView];
}



#pragma keyBoardDelegate
- (void)keyBoardUp{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, -80, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}


- (void)keyBoardHides{
    [self viewEndEditing];
}


#pragma threeDelegate
- (void)scrollViewTop{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, -80, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}


#pragma fourthDelegate
- (void)currentPay:(CGFloat)payMoney{
  NSLog(@"22222222");
    if (_weighttextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请填写货物重量"];
        return;
    }
    
    if (_singlePriceTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请填写成交单价"];
        return;
    }
    
    if (!_btnSelectedIndex) {
        [SVProgressHUD showErrorWithStatus:@"请选择废品种类"];
        return;
    }
    if ([_firstSectionStr isEqualToString:@"sectionOpen"] && [_secondSectionStr isEqualToString:@"firstOpen"]) {
        NSLog(@"老用户信息");
        if (_AuserID.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择老用户"];
            return;
        }
        [self commitOldUserInfo:payMoney];
    }else if([_firstSectionStr isEqualToString:@"sectionOpen"] && [_secondSectionStr isEqualToString:@"secondOpen"]){
        if (_phoneTextField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请填写联系电话"];
            return;
        }
        
        if(_phoneTextField.text.length < 11){
            [SVProgressHUD showErrorWithStatus:@"请填写正确的联系电话"];
            return;
        }
        
        if (_nameTextField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请填写姓名"];
            return;
        }
        
        if (!_lng||!_lat||_addressStr.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请填写地址"];
            return;
        }
        
        if (_city_nameLabel.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择地区"];
            return;
        }
    
        if (_phoneTextField.text.length > 0&&_nameTextField.text.length > 0&&_lng&&_lat&&_addressStr.length > 0&&_city_nameLabel.text.length > 0) {
            [self commitNewUser:payMoney];
        }
    }else if ([_firstSectionStr isEqualToString:@"sectionClose"]){
        [SVProgressHUD showErrorWithStatus:@"请选择老用户或者新用户"];
    }
}



- (void)commitNewUser:(CGFloat)payMoney{
    [GxqAlertView showWithdescText:@"提交新用户数据？" LeftText:@"取消" rightText:@"确定" LeftBlock:^{
    } RightBlock:^{
        [self commitNewUserInfo:payMoney];
    }];
}


- (void)commitOldUserInfo:(CGFloat)payMoney{
    [GxqAlertView showWithdescText:@"提交老用户数据?" LeftText:@"取消" rightText:@"确定" LeftBlock:^{
        
    } RightBlock:^{
        [self commitOldAllInfo:payMoney];
    }];
}


- (void)commitOldAllInfo:(CGFloat)money{
    __weak typeof(self)weakSelf = self;
    NSDictionary * jsonDic = @{@"json":@{@"supplier_id":_AuserID?_AuserID:_newUserID,
                                         @"weight":_weighttextField.text,
                                         @"one_money":_singlePriceTextField.text,
                                         @"money":@(money),
                                         @"pedlar_category_id":@(_btnSelectedIndex)}};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];
    NSDictionary * dic = @{@"call":@30205,@"json":jsonStr};
    BtAccount * acount = [BtAccountTool account];
    NSDictionary * aesDic = [AESSecurityUtil BtDataAESEncrypt:dic keyStr:stdString(acount.token)];
    [[NetWorking shareNet] netRequestParameter:aesDic success:^(id  _Nonnull json) {
        
        if ([json[@"state"]integerValue] == 1) {
            [weakSelf pushTradViewController];
            [SVProgressHUD showSuccessWithStatus:@"订单提交成功"];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}



- (void)commitNewUserInfo:(CGFloat)payMoney{
    NSDictionary * jsonDic = @{@"json":@{@"name":_nameTextField.text,
                                         @"mobile":_phoneTextField.text,
                                         @"address":@{@"lat":@(_lat),
                                                      @"lng":@(_lng),
                                                      @"address":_addressStr,
                                                      @"area_city":@"3307",
                                                      @"area_county":@"330784",
                                                      @"area_town":_cityCode,
                                                      @"area_province":@"33"}
                                        }};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];
    NSDictionary * dic = @{@"call":@20304,@"json":jsonStr};
    BtAccount * acount = [BtAccountTool account];
    NSDictionary * aesDic = [AESSecurityUtil BtDataAESEncrypt:dic keyStr:stdString(acount.token)];
    [[NetWorking shareNet] netRequestParameter:aesDic success:^(id  _Nonnull json) {
        
        if ([json[@"state"]integerValue] == 1) {
            _newUserID = json[@"info"];
            if (_newUserID) {
                [self commitOldAllInfo:payMoney];
            }
        }else if([json[@"state"] integerValue] == 0){
            if ([json[@"errorCode"]integerValue] == 20204) {
                 [SVProgressHUD showErrorWithStatus:json[@"errorMsg"]];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"访问服务器失败"];
    }];
}



- (void)pushTradViewController{
    tradingDataController * tradVC = [[tradingDataController alloc] init];
    tradVC.statusType = @"StatusConfirmation";
    [self.navigationController pushViewController:tradVC animated:YES];
}


- (void)threeTextFieldHides{
    [self viewEndEditing];
}



- (void)viewEndEditing{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        
    }];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    CGFloat amount = 0;
    if (textField == _singlePriceTextField) {
        NSString *singStr = [textField text];
        if (string.length > 0) {
            singStr = [singStr stringByAppendingString:string];
        } else {
            if ([singStr length] > 1) {
                singStr = [singStr substringToIndex:(singStr.length - 1)];
            } else {
                singStr = @"";
            }
        }
        CGFloat singlePrice = (singStr.length > 0) ? [singStr floatValue] : 0;
        NSString *weightStr = [_weighttextField text];
        CGFloat weight = (weightStr.length > 0) ? [weightStr floatValue] : 0;
        amount = weight * singlePrice;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MONEYTOTAL_NOTI" object:[NSString stringWithFormat:@"%.2f", amount] userInfo:nil];
        [self setAmountStr:amount];
       
    } else if (textField == _weighttextField) {
        NSString *singStr = [_singlePriceTextField text];
        CGFloat singlePrice = (singStr.length > 0) ? [singStr floatValue] : 0;
        NSString *weightStr = [textField text];
        if (string.length > 0) {
            weightStr = [weightStr stringByAppendingString:string];
        } else {
            if ([weightStr length] > 1) {
                weightStr = [weightStr substringToIndex:(weightStr.length - 1)];
            } else {
                weightStr = @"";
            }
        }
        CGFloat weight = (weightStr.length > 0) ? [weightStr floatValue] : 0;
        amount = weight * singlePrice;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MONEYTOTAL_NOTI" object:[NSString stringWithFormat:@"%.2f", amount] userInfo:nil];

        [self setAmountStr:amount];
    }else if (textField == _youhuiTextField){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MONEYTOTAL_NOTIYouH" object:[NSString stringWithFormat:@"%.2f", amount] userInfo:nil];
        [self setAmountStr:amount];
    }
    NSLog(@"这个字典里的值是啥:%@",_dict);
    return YES;
}



- (void)setAmountStr:(CGFloat)amount{
    if (amount != 0.00) {
           NSString * string = [NSString stringWithFormat:@"%.2f",amount];
        [_dict setObject:string forKey:@"amount"];
    }
 
}



- (void)textDidChangeName:(NSNotification *)changeNane{
    if (_phoneTextField.text != nil) {
        [_allDict setObject:_phoneTextField.text forKey:@"phone"];
    }
    if (_nameTextField.text != nil) {
        [_allDict setValue:_nameTextField.text forKey:@"name"];
    }
    [_allDict setObject:_weighttextField.text forKey:@"weight"];
    [_allDict setObject:_singlePriceTextField.text forKey:@"price"];
    
   
    if (_phoneTextField.text.length > 11) {
        _phoneTextField.text = [_phoneTextField.text substringToIndex:11];
    }
    if (_nameTextField.text.length > 20) {
        _nameTextField.text = [_nameTextField.text substringToIndex:20];
    }
    
    if ([_singlePriceTextField.text containsString:@".."]) {
        _singlePriceTextField.text = [_singlePriceTextField.text stringByReplacingOccurrencesOfString:@".." withString:@"."];
    }
    if ([_weighttextField.text containsString:@".."]) {
        _weighttextField.text = [_weighttextField.text stringByReplacingOccurrencesOfString:@".." withString:@"."];
    }
    
    for (NSInteger i = 0; i < 9; i++) {
        NSString * string = [NSString stringWithFormat:@"0%ld",(long)i];
        if ([_youhuiTextField.text isEqualToString:string]) {
            _youhuiTextField.text = [_youhuiTextField.text stringByReplacingOccurrencesOfString:string withString:@"0"];
        }
        if ([_singlePriceTextField.text isEqualToString:string]) {
            _singlePriceTextField.text = [_singlePriceTextField.text stringByReplacingOccurrencesOfString:string withString:@"0"];
        }
        if ([_weighttextField.text isEqualToString:string]) {
            _weighttextField.text = [_weighttextField.text stringByReplacingOccurrencesOfString:string withString:@"0"];
        }
    }
    
    
    if ([_singlePriceTextField.text containsString:@"."]) {
        NSString * pointStr = @".";
        NSRange StartRange = [_singlePriceTextField.text rangeOfString:pointStr options:NSCaseInsensitiveSearch];
        NSString * singlePriceLength = [_singlePriceTextField.text substringFromIndex:StartRange.location];//获取点后面的长度
        for (NSInteger i = 0; i < 10; i++) {
            NSString * string = [NSString stringWithFormat:@".%ld.",(long)i];
            NSString * string1 = [NSString stringWithFormat:@".%ld",(long)i];
            if ([singlePriceLength containsString:string]) {
                singlePriceLength = [singlePriceLength stringByReplacingOccurrencesOfString:string withString:string1];
            }
        }
        NSString * pointBehind = [_singlePriceTextField.text substringToIndex:StartRange.location];//获取点之前的长度
        if (pointBehind.length > 5) {
            [pointBehind substringToIndex:5];
        }
        if (singlePriceLength.length > 3) {
            singlePriceLength = [singlePriceLength substringToIndex:3];
        }
        _singlePriceTextField.text = [_singlePriceTextField.text substringToIndex:pointBehind.length+singlePriceLength.length];
    }else if(_singlePriceTextField.text.length > 5){
        _singlePriceTextField.text = [_singlePriceTextField.text substringToIndex:5];
    }
    
    if ([_weighttextField.text containsString:@"."]) {
        NSString * pointStr = @".";
        NSRange startRange = [_weighttextField.text rangeOfString:pointStr options:NSCaseInsensitiveSearch];
        NSString * singleWeightLength = [_weighttextField.text substringFromIndex:startRange.location];//获取点后面的长度
        for (NSInteger i = 0; i < 10; i++) {
            NSString * string = [NSString stringWithFormat:@".%ld.",(long)i];
            NSString * string1 = [NSString stringWithFormat:@".%ld",(long)i];
            if ([singleWeightLength containsString:string]) {
                singleWeightLength = [singleWeightLength stringByReplacingOccurrencesOfString:string withString:string1];
            }
        }
        NSString * pointBehind = [_weighttextField.text substringToIndex:startRange.location];//获取点之前的长度
        if (singleWeightLength.length > 3) {
            singleWeightLength = [singleWeightLength substringToIndex:3];
        }
        if (pointBehind.length > 6) {
            pointBehind = [pointBehind substringToIndex:6];
        }
        _weighttextField.text = [_weighttextField.text substringToIndex:pointBehind.length+singleWeightLength.length];
    }else if (_weighttextField.text.length > 6){
        _weighttextField.text = [_weighttextField.text substringToIndex:6];
    }
    
    if ([_youhuiTextField.text containsString:@"."]) {
        NSString * pointStr = @".";
        NSRange startRange = [_youhuiTextField.text rangeOfString:pointStr options:NSCaseInsensitiveSearch];
        NSString * singleYouhuiLength = [_youhuiTextField.text substringFromIndex:startRange.location];//获取后面的长度
        
        for (NSInteger i = 0; i < 10; i++) {
            NSString * string = [NSString stringWithFormat:@".%ld.",(long)i];
            NSString * string1 = [NSString stringWithFormat:@".%ld",(long)i];
            if ([singleYouhuiLength containsString:string]) {
                singleYouhuiLength = [singleYouhuiLength stringByReplacingOccurrencesOfString:string withString:string1];
            }
        }
        
        NSString * pointBehind = [_youhuiTextField.text substringToIndex:startRange.location];//获取点之前的长度
        if (singleYouhuiLength.length > 3) {
            singleYouhuiLength = [singleYouhuiLength substringToIndex:3];
        }
        if (pointBehind.length > 8) {
            pointBehind = [pointBehind substringToIndex:8];
        }
        _youhuiTextField.text = [_youhuiTextField.text substringToIndex:pointBehind.length+singleYouhuiLength.length];
    }else if (_youhuiTextField.text.length > 8){
        _youhuiTextField.text = [_youhuiTextField.text substringToIndex:8];
    }
    [_allDict setObject:_youhuiTextField.text forKey:@"youhui"];
   
}

//requireInteral
- (void)dealloc{
    [kUserDefaults removeObjectForKey:@"requireInteral"];
}



@end
