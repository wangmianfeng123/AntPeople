//
//  orderTotalViewController.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/20.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#import "orderTotalViewController.h"
#import "allOrderViewController.h"
#import "getOrderViewController.h"
#import "orderTableViewCell.h"
#import "tradingDataController.h"
#import "orderInfoViewController.h"
#import "waitingResponseController.h"
#import "BtPapawView.h"
#import "resultModel.h"
#import "orderTotalModel.h"
#import "noOrderView.h"



@interface orderTotalViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *orderTotalTableView;
@property (nonatomic,strong) resultModel * resultModel;
@property (nonatomic,strong) noOrderView * noorderView;
@property (nonatomic,strong) NSMutableArray * mArr;
@property (nonatomic,strong) infoOrderModel * infoModel;
@property (nonatomic,assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger currentPage;
@end
@implementation orderTotalViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [BtPushManagerTool sharedPushManager].observerPushInfoBlock = ^(BtPushInfoModel * _Nonnull pushInfo, NSNumber * _Nonnull userStatus, NSInteger refresh) {
        if (!refresh) {
        }
        NSLog(@"hhhhhhhhhhome %@", userStatus);
        [BtPushManagerTool checkUserCurrentStatus:self animate:YES];
        if ([userStatus isEqualToNumber:@6] || [userStatus isEqualToNumber:@5]) {// 订单已被评价
            self.currentPage = 1;
            [self refresh];
        }
    };
}


- (void)viewDidLoad {
    [super viewDidLoad];
   VIEW_BACKCOLOR
    if (@available(iOS 11.0, *)) {//导航栏添加阴影
         [self.navigationController.navigationBar shadowWithColor:[networkTool colorWithHexString:@"#e0e0e0"] shadowOffSet:CGSizeMake(0, 2) shadowOpacity:0.4];
    } else {
    }
    self.currentPage = 1;
    self.totalPage = 1;
    self.mArr = [[NSMutableArray alloc] init];
    [self addRightBarButtonItemWithTitle:@"全部订单" action:@selector(rightBarAction:)];
    [self addLeftBarButtonWithTitle:@"代下单" action:@selector(leftBarAction:)];
    
     [_orderTotalTableView registerNib:[UINib nibWithNibName:@"orderTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellid"];
    _orderTotalTableView.delegate = self;
    _orderTotalTableView.dataSource = self;
    _orderTotalTableView.backgroundColor = [networkTool colorWithHexString:@"#f5f5f5"];
    _orderTotalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    BtAccount * bt = [BtAccountTool account];
    if (bt) {
        _resultModel = [resultModel mj_objectWithKeyValues:bt];
    }
}


- (noOrderView *)noorderView{
    if (!_noorderView) {
        _noorderView = [[noOrderView alloc] initWithFrame:CGRectMake(0, kTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT) type:@"orderTotal"];
    }
    return _noorderView;
}


- (void)leftBarAction:(UIButton *)btn{
    NSLog(@"左侧按钮");
    orderInfoViewController * orderInfo = [[orderInfoViewController alloc] init];
    orderInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderInfo animated:YES];
}


- (void)rightBarAction:(UIButton *)btn{
    allOrderViewController * allOrderVC = [[allOrderViewController alloc] init];
    allOrderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:allOrderVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(15, 0, SCREEN_WIDTH-30, 10);
    view.backgroundColor = [networkTool colorWithHexString:@"#f5f5f5"];
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.02f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 5;
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _mArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    orderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    _infoModel = _mArr[indexPath.section];
    NSLog(@"查看这个页面的信息:%@",_infoModel);
    cell.infoModel = _infoModel;
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    orderDetailViewController * orderDetail = [[orderDetailViewController alloc] init];
    _infoModel = _mArr[indexPath.section];
    orderDetail.orderId = _infoModel.ID;
    orderDetail.hidesBottomBarWhenPushed = YES;
  
    
     waitingResponseController * waitingVC = [[waitingResponseController alloc] init];
    waitingVC.hidesBottomBarWhenPushed = YES;
    _infoModel = _mArr[indexPath.section];
    waitingVC.orderId = _infoModel.ID;
    
    orderInfoViewController * orderInfo = [[orderInfoViewController alloc] init];
    orderInfo.supplier_id = _infoModel.supplier_id;
    orderInfo.hidesBottomBarWhenPushed = YES;

    if ([_infoModel.status integerValue] == 5 || [_infoModel.status integerValue] == 0|| [_infoModel.status integerValue] == 1 || [_infoModel.status integerValue] == 2 || [_infoModel.status integerValue] == 6) {
        [self.navigationController pushViewController:waitingVC animated:YES];
    }else if([_infoModel.status integerValue] == 3 || [_infoModel.status integerValue] == 4 ){
        [self.navigationController pushViewController:orderDetail animated:YES];
    }
//    else if([_infoModel.status integerValue] == 6){
//        [self.navigationController pushViewController:orderInfo animated:YES];
//    }
}



- (void)refresh{
    self.totalPage = 1;
    //上拉加载
    _orderTotalTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self prepareLoadData:YES];
    }];
    //下拉刷新
    _orderTotalTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_orderTotalTableView.mj_header endRefreshing];
        [self prepareLoadData:NO];
    }];
    [_orderTotalTableView.mj_header beginRefreshing];
}


- (void)prepareLoadData:(BOOL)isMore{
    static NSInteger page = 1;
    if (!isMore) {
        page = 1;
    }else{
        page++;
    }
    [self request:isMore page:page];
}

#pragma - 未完待续 -
- (void)request:(BOOL)ismore page:(NSInteger)page{
    if (page > self.totalPage) {
        [self.orderTotalTableView.mj_footer endRefreshing];
        return;
    }
    NSDictionary * jsonDict = @{@"page":@{@"showCount":@(10),@"currentPage":@(page)}};
    NSString * jsonStr = [NetWorking returnJson:jsonDict];
    NSDictionary * jsonDic = @{@"call":@30003,@"json":jsonStr};
    [infoOrderModel loadOrderListInfo:jsonDic success:^(NSArray *feedback, BOOL status) {
        
        if (page == 1) {
            [_mArr removeAllObjects];
            ismore?[_orderTotalTableView.mj_footer endRefreshing]:[_orderTotalTableView.mj_header endRefreshing];
        }else{
            ismore?[_orderTotalTableView.mj_footer endRefreshing]:[_orderTotalTableView.mj_header endRefreshing];
        }
        if (status) {
            infoOrderModel * infoOrderTotalM = [feedback firstObject];
            orderTotalModel * orderTotal = infoOrderTotalM.page;
            if (orderTotal.totalPage > 0) {
                self.totalPage = orderTotal.totalPage;
            }
            [self.mArr addObjectsFromArray:feedback];
        }
        if (self.mArr.count == 0) {
            self.noorderView.hidden = NO;
            [self loadingNoOrderView];
        }else{
            self.noorderView.hidden = YES;
            self.orderTotalTableView.hidden = NO;
        }
        [self.orderTotalTableView reloadData];
         ismore?[_orderTotalTableView.mj_footer endRefreshing]:[_orderTotalTableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
         ismore?[_orderTotalTableView.mj_footer endRefreshing]:[_orderTotalTableView.mj_header endRefreshing];
    }];
}


- (void)loadingNoOrderView{
    self.orderTotalTableView.hidden = YES;
    [self.view addSubview:self.noorderView];
}

@end
