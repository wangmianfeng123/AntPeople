//
//  orderDetailViewController.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/20.
//  Copyright © 2017年 王绵峰. All rights reserved.
//

#import "waitingResponseController.h"
#import "infoDetailModel.h"
#import "tradingDataController.h"
#import "waittingResponseCell.h"
#import "getOrderViewController.h"
#import "responseCell.h"
#import "MANaviRoute.h"
#import "CommonUtility.h"

static const NSInteger RoutePlaningPaddingEdge = 70;

@interface waitingResponseController ()<MAMapViewDelegate,UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate,responseDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapTopConstraint;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *orderDetailTableView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *autographLabel;
@property (nonatomic,strong) MAPointAnnotation * BuserAnnomation;
@property (nonatomic,strong) MAPointAnnotation * AuserAnnomation;
@property (nonatomic,assign) CLLocationCoordinate2D startCoordinate;//起点经纬度
@property (nonatomic,assign) CLLocationCoordinate2D destinationCoordinate;//终点经纬度
@property (nonatomic,strong) AMapSearchAPI * searchApi;
@property (nonatomic,strong) AMapRoute * route;//路径规划信息
@property (nonatomic,assign) NSUInteger totalRouteNums;//总规划路线条数
@property (nonatomic,assign) NSUInteger currentRouteIndex;//当前路线索引值，从零开始
@property (nonatomic,strong) MANaviRoute * naviRoute;//用于显示当前路线方案
@property (nonatomic,strong) infoDetailModel * infoModel;


@end

@implementation waitingResponseController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
    } else {
        self.mapTopConstraint.constant = 64.f;
    }
    UIColor * color = [UIColor lightGrayColor];
    self.navigationItem.title = @"订单详情";
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_normal_icon"] action:@selector(backaction:)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    self.mapView.delegate = self;
    //头像添加圆角
    self.iconImg.layer.cornerRadius = self.iconImg.frame.size.width/2;
    self.iconImg.layer.masksToBounds = YES;
    
    //添加地图
    [AMapServices sharedServices].enableHTTPS = YES;
    [_topView shadowWithColor:color shadowOffSet:CGSizeMake(3, 3) shadowOpacity:0.5];//添加阴影
    _orderDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _orderDetailTableView.delegate = self;
    _orderDetailTableView.dataSource = self;
    _orderDetailTableView.showsVerticalScrollIndicator = NO;
    [_orderDetailTableView registerNib:[UINib nibWithNibName:@"waittingResponseCell" bundle:nil] forCellReuseIdentifier:@"cellId"];
    [_orderDetailTableView registerNib:[UINib nibWithNibName:@"responseCell" bundle:nil] forCellReuseIdentifier:@"responseId"];
    BtAccount * bt = [BtAccountTool account];
    if (bt) {
        resultModel * Model = [resultModel mj_objectWithKeyValues:bt];
        NSString * token = Model.token;
        [self netpostOrderDetail:token orderId:_orderId];
    }
    
    [BtPushManagerTool sharedPushManager].observerPushInfoBlock = ^(BtPushInfoModel * _Nonnull pushInfo, NSNumber * _Nonnull userStatus, NSInteger refresh) {
        if (!refresh) {
        }
        [BtPushManagerTool checkUserCurrentStatus:self animate:YES];
    };
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)backaction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}


//B端位置
- (MAPointAnnotation *)BuserAnnomation{
    if (!_BuserAnnomation) {
        _BuserAnnomation = [[MAPointAnnotation alloc] init];
    }
    return _BuserAnnomation;
}


//A端位置
- (MAPointAnnotation *)AuserAnnomation{
    if (!_AuserAnnomation) {
        _AuserAnnomation = [[MAPointAnnotation alloc] init];
    }
    return _AuserAnnomation;
}



- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if (response.route == nil) {
        return;//初始化失败
    }
    self.route = response.route;
    self.totalRouteNums = response.route.paths.count;
    [self presentCurrentRouteCourse];
}


- (void)presentCurrentRouteCourse{
    if (self.totalRouteNums <= 0) {
        return;
    }
    [self.naviRoute removeFromMapView];
    MANaviAnnotationType type       = MANaviAnnotationTypeDrive;//骑行类型
    AMapGeoPoint * startPoint       = [AMapGeoPoint locationWithLatitude:self.BuserAnnomation.coordinate.latitude longitude:self.BuserAnnomation.coordinate.longitude];//起点
    AMapGeoPoint * endPoint         = [AMapGeoPoint locationWithLatitude:self.AuserAnnomation.coordinate.latitude longitude:self.AuserAnnomation.coordinate.longitude];//终点
    self.naviRoute                  = [MANaviRoute naviRouteForPath:self.route.paths[self.currentRouteIndex] withNaviType:type showTraffic:NO startPoint:startPoint endPoint:endPoint];//根据已规划的路线起点终点生成显示方案
    [self.naviRoute addToMapView:self.mapView];
    UIEdgeInsets edgePaddingRect    = UIEdgeInsetsMake(RoutePlaningPaddingEdge, RoutePlaningPaddingEdge, RoutePlaningPaddingEdge, RoutePlaningPaddingEdge);
    //缩放地图使其适应polylines的展示
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines] edgePadding:edgePaddingRect animated:YES];
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        if (annotation == self.AuserAnnomation) {
            annotationView.image = [UIImage imageNamed:@"移动定位icon"];
        }else if (annotation == self.BuserAnnomation){
            annotationView.image = [UIImage imageNamed:@"定位icon"];//
            annotationView.centerOffset = CGPointMake(2, -12);
        }
        return annotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    if ([overlay isKindOfClass:[LineDashPolyline class]]) {
        MAPolylineRenderer * polylineView = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineView.lineWidth    = 8.0f;
        polylineView.strokeImage = [UIImage imageNamed:@"bt_nav_route_line"];
        polylineView.lineCapType = kMALineCapRound;
        polylineView.lineJoinType = kMALineJoinRound;
        return polylineView;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]]) {//showTraffic为NO时，不需要带实时路况，路径为单一颜色
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        polylineRenderer.lineCapType = kMALineCapRound;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineWidth = 8;
        polylineRenderer.strokeImage = [UIImage imageNamed:@"bt_nav_route_line"];
        return polylineRenderer;
    }
    return nil;
}



- (void)netpostOrderDetail:(NSString *)token orderId:(NSString *)order{//获取订单详情信息数据
    NSDictionary * jsonDic = @{@"json":@{@"id":order}};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];
    NSDictionary * dic = @{@"call":@"30002",@"json":jsonStr};
    [infoDetailModel loadOrderDetailInfo:dic success:^(infoDetailModel *infoDetailModel, BOOL status) {
        if (status) {
            _infoModel = infoDetailModel;
            [self showUserInFo];
            [_orderDetailTableView reloadData];
        }
    } failure:^(NSError *error) {
    }];
}


#pragma responseDelegate//_twoModel.pedlar.car_id
- (void)responseMapView{
    NSLog(@"点击啊响应按钮");
    [self responseOrderContonue];
}



- (void)responseOrderContonue{
    NSDictionary * jsonDic = @{@"json":@{@"id":_orderId}};
    NSString * jsonStr = [NetWorking returnJson:jsonDic[@"json"]];
    NSDictionary * dic = @{@"call":@"30206",@"json":jsonStr};
    BtAccount * account = [BtAccountTool account];
    NSDictionary * aesDic = [AESSecurityUtil BtDataAESEncrypt:dic keyStr:stdString(account.token)];
    [[NetWorking shareNet] netRequestParameter:aesDic success:^(id  _Nonnull json) {
        
        if ([json[@"state"] integerValue] == 1) {
            [SVProgressHUD dismiss];
             [BtAccount synchroScraptMasterStatus];
        }else{
            [SVProgressHUD showErrorWithStatus:json[@"errorMsg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"访问服务器失败"];
    }];
}



#pragma tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    waittingResponseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    responseCell * responseCell = [tableView dequeueReusableCellWithIdentifier:@"responseId"];
    if (indexPath.section == 0) {
        [cell setInfoDetailModel:_infoModel indexPath:indexPath];
        return cell;
    }else{
        responseCell.delegate = self;
        return responseCell;
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else{
        return 1;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 40;
    }else{
         return 200;
    }
}


- (void)showUserInFo{
    _userNameLabel.text = _infoModel.supplier_name;
    [_iconImg sd_setImageWithURL:[NSURL URLWithString:_infoModel.supplier_head] placeholderImage:[UIImage imageNamed:@"订单_icon"]];
    if (_infoModel.supplier.signature == nil) {
        self.autographLabel.text = @"我可以跟在你身后，像影子追着光梦游";
    }else{
        self.autographLabel.text = _infoModel.supplier.signature;
    }
    self.startCoordinate = CLLocationCoordinate2DMake(_infoModel.supplier_lat.doubleValue, _infoModel.supplier_lng.doubleValue);
    
    if (_infoModel.pedlar_lat.length == 0) {
        self.destinationCoordinate = CLLocationCoordinate2DMake(_infoModel.supplier_lat.doubleValue, _infoModel.supplier_lng.doubleValue);
    }else{
        self.destinationCoordinate = CLLocationCoordinate2DMake(_infoModel.pedlar_lat.doubleValue, _infoModel.pedlar_lng.doubleValue);
    }
    self.AuserAnnomation.coordinate = self.destinationCoordinate;//A端的位置
    self.BuserAnnomation.coordinate = self.startCoordinate;//B端的位置
    [self.mapView addAnnotation:self.AuserAnnomation];
    [self.mapView addAnnotation:self.BuserAnnomation];
    AMapDrivingRouteSearchRequest * navi        = [[AMapDrivingRouteSearchRequest alloc] init];
    navi.origin                                = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude]; /*出发点*/
    navi.destination                           = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude]; /*目的地*/
    [self.searchApi AMapDrivingRouteSearch:navi];
    [self.mapView setZoomLevel:16];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

