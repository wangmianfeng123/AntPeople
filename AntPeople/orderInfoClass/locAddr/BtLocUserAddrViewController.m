//
//  BtLocUserAddrViewController.m
//  ScrapMaster
//
//  Created by BNT-FS01 on 2017/12/8.
//  Copyright © 2017年 BNT-FS01. All rights reserved.
//

#import "BtLocUserAddrViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "BtMapAddrTableViewCell.h"
#import "CJCustomPinAnnotationView.h"

@interface BtLocUserAddrViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *keySearchView;
@property (nonatomic, strong) UIView *fieldView;
@property (nonatomic, strong) UIImageView *searchImgView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIView *searchInfoView;
@property (nonatomic, strong) UITableView *searTableView;
@property (nonatomic, strong) UIButton *endSearchBtn;
@property (nonatomic, strong) UIButton *findButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIView *btmLineView;
@property (nonatomic, strong) NSMutableArray *searDataArray;// 搜索结果
@property (nonatomic, strong) UIView *noResultView;
@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, strong) MAMapView *aMapView;
@property (nonatomic, strong) AMapSearchAPI *aMapSearch;
@property (nonatomic, strong) AMapLocationManager *locManager;// 定位
@property (nonatomic, copy) NSString *poiCityStr;// 兴趣点城市
@property (nonatomic, strong) AMapGeoPoint *poiCityGeo;// 兴趣点经纬度
@property (nonatomic, strong) MAPointAnnotation *lockedPointAnno;// 中心固定标记
@property (nonatomic, strong) NSMutableArray *poiAnnoArray;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITableView *addTableView;
@property (nonatomic, strong) NSMutableArray *locAddrArray;// 兴趣点信息列表
@property (nonatomic, strong) UIView *unKnowView;

@end

@implementation BtLocUserAddrViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.poiCityStr = @"杭州";
    self.isSearch = NO;
     [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_normal_icon"] action:@selector(backAction:)];
    self.title = @"地址编辑";
    self.locAddrArray = [[NSMutableArray alloc] init];
    self.poiAnnoArray = [[NSMutableArray alloc] init];
    
    [self configAMapView];
    [self configBottomView];
    [self configSearchView];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.aMapView.showsUserLocation = YES;
    self.aMapView.userTrackingMode = MAUserTrackingModeFollow;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.aMapView.showsUserLocation = NO;
}
#pragma mark - AMapView
- (void)configAMapView
{
    if (kIphoneX) {
         self.aMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0.f, 132, SCREEN_WIDTH, (SCREEN_HEIGHT-44)/2)];
    }else{
        self.aMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0.f, 108, SCREEN_WIDTH, (SCREEN_HEIGHT-44)/2)];
    }
    [self.view addSubview:self.aMapView];
    
    self.aMapView.delegate = self;
    [self.aMapView setZoomLevel:16.f animated:YES];
    self.aMapSearch = [[AMapSearchAPI alloc] init];
    self.aMapSearch.delegate = self;
    [self requestLocationAddrInfo];
}


//返回按钮
- (void)backAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}



// 获取定位信息
- (void)requestLocationAddrInfo
{
    self.locManager = [[AMapLocationManager alloc] init];
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    self.locManager.locationTimeout = 2.f;
    self.locManager.reGeocodeTimeout = 2.f;
    weakify(self);
    [self.locManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
            NSLog(@"location Error");
        }
        strongify(self);
        if (regeocode) {
            self.poiCityStr = regeocode.city;
            self.poiCityGeo = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            if (!self.lockedPointAnno) {
                self.lockedPointAnno = [[MAPointAnnotation alloc] init];
                self.lockedPointAnno.coordinate = location.coordinate;
                [self.aMapView addAnnotation:self.lockedPointAnno];
            }
        }
        [self searchPoiInfoInCity];
    }];
}
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    if (self.lockedPointAnno.coordinate.latitude != 0 && self.lockedPointAnno.coordinate.longitude != 0) {
        CLLocationDistance distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(self.aMapView.userLocation.coordinate), MAMapPointForCoordinate(self.lockedPointAnno.coordinate));
        NSLog(@"Locked Point Coordinate lat:%f  lon:%f  distance %f", self.lockedPointAnno.coordinate.latitude, self.lockedPointAnno.coordinate.longitude, distance);
        if (distance > 10) {
            self.poiCityGeo = [AMapGeoPoint locationWithLatitude:self.lockedPointAnno.coordinate.latitude longitude:self.lockedPointAnno.coordinate.longitude];
            [self searchPoiInfoInCity];
        }
    }
    
}
#pragma mark - map Search
// 城市内地图周边检索
- (void)searchPoiInfoInCity
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = self.poiCityGeo;
    request.sortrule = 0;
    request.requireExtension = YES;
    
    [self.aMapSearch AMapPOIAroundSearch:request];
}
// 关键字搜索
- (void)searchPoiInfoWithKeyword:(NSString *)keyword
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    request.city = self.poiCityStr;
    request.requireExtension = YES;
    
    [self.aMapSearch AMapPOIKeywordsSearch:request];
}
// 地图POI搜索结果
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0) {
        if (self.isSearch) {
            [self.searDataArray removeAllObjects];
            [self.searTableView reloadData];
            self.noResultView.hidden = NO;
        } else {
            [self.aMapView removeAnnotations:self.poiAnnoArray];
            [self.poiAnnoArray removeAllObjects];
            [self.locAddrArray removeAllObjects];
            [self.addTableView reloadData];
            self.unKnowView.hidden = NO;
        }
        return;
    }
    if (!self.isSearch) {
        // 地图周边搜索
        [self.aMapView removeAnnotations:self.poiAnnoArray];
        [self.poiAnnoArray removeAllObjects];
        [self.locAddrArray removeAllObjects];
        [self.locAddrArray addObjectsFromArray:response.pois];
        for (int i = 0; i < self.locAddrArray.count; i++) {
            AMapPOI *poiPoint = self.locAddrArray[i];
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(poiPoint.location.latitude, poiPoint.location.longitude);
            pointAnnotation.title = poiPoint.name;
            pointAnnotation.subtitle = [NSString stringWithFormat:@"%@%@%@", poiPoint.district, poiPoint.address, poiPoint.name];
            [self.aMapView addAnnotation:pointAnnotation];
            [self.poiAnnoArray addObject:pointAnnotation];
        }
        self.unKnowView.hidden = YES;
        [self.addTableView reloadData];
    } else {
        // 关键字搜索
        [self.searDataArray removeAllObjects];
        [self.searDataArray addObjectsFromArray:response.pois];
        self.noResultView.hidden = YES;
        [self.searTableView reloadData];
    }
    
}
#pragma mark - MAAnnotationView
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]] && annotation != mapView.userLocation) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        if (annotation == self.lockedPointAnno) {
            MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
                [self.lockedPointAnno setLockedScreenPoint:CGPointMake(CGRectGetWidth(self.aMapView.frame) / 2.f, CGRectGetHeight(self.aMapView.frame) / 2.f)];
                [self.lockedPointAnno setLockedToScreen:YES];
            }
            annotationView.canShowCallout = NO;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
            annotationView.image = [UIImage imageNamed:@"bt_location_map_center"];
            annotationView.centerOffset = CGPointMake(0.f, -10.f);
            
            return annotationView;
        } else {
            CJCustomPinAnnotationView *annotationView = (CJCustomPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[CJCustomPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.customAnnoBlock = ^(NSString *addrStr, CGFloat lat, CGFloat lon) {
                [self selectAddrInfo:addrStr lat:lat lon:lon];
            };
            annotationView.canShowCallout = NO; // 设置为NO，用以调用自定义的calloutView
            annotationView.animatesDrop = YES; //设置标注动画显示，默认为NO
            annotationView.draggable = NO;  //设置标注可以拖动，默认为NO
            annotationView.pinColor = MAPinAnnotationColorRed;
            
            annotationView.centerOffset = CGPointMake(0.f, -18.f);
            
            return annotationView;
        }
    }
    
    return nil;
}



- (void)configBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(self.aMapView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(self.aMapView.frame))];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    _addTableView = [[UITableView alloc] initWithFrame:_bottomView.bounds style:UITableViewStylePlain];
    _addTableView.backgroundColor = [UIColor whiteColor];
    _addTableView.delegate = self;
    _addTableView.dataSource = self;
    _addTableView.separatorColor = [networkTool colorWithHexString:@"#cccccc"];
    _addTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _addTableView.separatorInset = UIEdgeInsetsMake(0.f, 20.f, 0.f, 0.f);
    
    [_addTableView registerNib:[UINib nibWithNibName:@"BtMapAddrTableViewCell" bundle:nil] forCellReuseIdentifier:@"BtMapAddrTableViewCell"];
    
    [_bottomView addSubview:_addTableView];
    [self.view addSubview:_bottomView];
}



- (void)configSearchView
{
    _searDataArray = [[NSMutableArray alloc] init];
    
    _keySearchView = [[UIView alloc] initWithFrame:CGRectMake(0.f, kTopHeight, SCREEN_WIDTH, 44.f)];
    [_keySearchView setBackgroundColor:[UIColor whiteColor]];
//    [_keySearchView addShadowColor:CJHexColor(0xe4e4e4, 1.f) offSet:CGSizeMake(0.f, 4.f) opacity:0.4f];
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.frame = CGRectMake(SCREEN_WIDTH, 2.f, 60.f, 40.f);
    _searchButton.backgroundColor = [UIColor clearColor];
    [_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [_searchButton setTitleColor:[UIColor colorWithRed:42/255.0 green:144/255.0 blue:253/255.0 alpha:1.0] forState:UIControlStateNormal];//42 144 253
    _searchButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [_searchButton addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_keySearchView addSubview:_searchButton];
    _searchButton.hidden = YES;
    _fieldView = [[UIView alloc] initWithFrame:CGRectMake(20.f, 7.f, SCREEN_WIDTH - 40.f, 30.f)];

    _fieldView.layer.cornerRadius = 15.f;
    [_fieldView setBackgroundColor:[networkTool colorWithHexString:@"#eaeaea"]];
    [_keySearchView addSubview:_fieldView];
    CGSize txtSize = [networkTool sizeOfString:@"请输入你想要搜索的地址" limitSize:CGSizeMake(SCREEN_WIDTH, 20.f) fontSize:15.f];
    CGFloat width = txtSize.width + 17.f + 6.f;
    _searchImgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - width) / 2.f, (44.f - 17.f) / 2.f, 17.f, 17.f)];
    [_searchImgView setImage:[UIImage imageNamed:@"bt_search_icon"]];
    [_keySearchView addSubview:_searchImgView];
     _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_searchImgView.frame) + 6.f, 7.f, txtSize.width, 30.f)];
    _searchTextField.font = [UIFont systemFontOfSize:15.f];
    _searchTextField.placeholder = @"请输入你想要搜索的地址";
    [_keySearchView addSubview:_searchTextField];
    _findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_findButton setBackgroundColor:[UIColor clearColor]];
    [_findButton addTarget:self action:@selector(findButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _findButton.frame = _keySearchView.bounds;
    [_keySearchView addSubview:_findButton];
    _btmLineView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 43.5f, SCREEN_WIDTH, 0.5)];
    _btmLineView.backgroundColor = [networkTool colorWithHexString:@"#eaeaea"];
    [_keySearchView addSubview:_btmLineView];
        _btmLineView.hidden = YES;
    _endSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _endSearchBtn.frame = CGRectMake(0.f, 2.f, 50.f, 40.f);
    _endSearchBtn.backgroundColor = [UIColor clearColor];//
    [_endSearchBtn setImageEdgeInsets:UIEdgeInsetsMake(10.25f, 10.f, 10.25f, 29.f)];
    [_endSearchBtn setImage:[UIImage imageNamed:@"back_normal_icon"] forState:UIControlStateNormal];
    [_endSearchBtn addTarget:self action:@selector(endSearchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_keySearchView addSubview:_endSearchBtn];
    _endSearchBtn.hidden = YES;
    [self.view addSubview:_keySearchView];
    
    _searchInfoView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(_keySearchView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - kTopHeight)];
    _searchInfoView.backgroundColor = [UIColor whiteColor];
    _searTableView = [[UITableView alloc] initWithFrame:_searchInfoView.bounds style:UITableViewStylePlain];
    _searTableView.delegate = self;
    _searTableView.dataSource = self;
//    _searTableView.separatorColor = CJHexColor(0xcccccc, 1.f);
    _searTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searTableView.separatorInset = UIEdgeInsetsMake(0.f, 20.f, 0.f, 0.f);
    [_searTableView registerNib:[UINib nibWithNibName:@"BtMapAddrTableViewCell" bundle:nil] forCellReuseIdentifier:@"BtMapAddrTableViewCell"];
    [_searchInfoView addSubview:_searTableView];
    [self.view addSubview:_searchInfoView];
    _searchInfoView.hidden = YES;
}
- (void)findButtonAction
{
    self.isSearch = YES;
    [self changeKeySearchSatus:YES];
    [UIView animateWithDuration:0.3f animations:^{
        self.searchInfoView.alpha = 1.f;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.searchInfoView.frame = CGRectMake(0.f,kTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kTopHeight);
        self.keySearchView.frame = CGRectMake(0.f, kTopHeight - 44.f, SCREEN_WIDTH, 44.f);
        self.searchButton.frame = CGRectMake(SCREEN_WIDTH - 60.f, 2.f, 60.f, 40.f);
        self.fieldView.frame = CGRectMake(32.f, 7.f, SCREEN_WIDTH - 32.f - 60.f, 30.f);
        self.searchImgView.frame = CGRectMake(32.f + 15.f, (44.f - 17.f) / 2.f, 17.f, 17.f);
        self.searchTextField.frame = CGRectMake(72.f, 7.f, SCREEN_WIDTH - 148.f, 30.f);
        self.btmLineView.alpha = 1.f;
        self.endSearchBtn.alpha = 1.f;
//        self.btNavigationBar.frame = CGRectMake(0.f, - kNavBarHeight, SCREEN_WIDTH, kNavBarHeight);
    } completion:^(BOOL finished) {
        [self.searchTextField becomeFirstResponder];
    }];
}
- (void)searchBtnAction
{
    [self.view endEditing:YES];
    NSString *keywords = self.searchTextField.text;
    [self searchPoiInfoWithKeyword:keywords];
}
- (void)endSearchBtnAction
{
    [self.view endEditing:YES];
    self.searchTextField.text = @"";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    CGSize txtSize = [networkTool sizeOfString:@"请输入你想要搜索的地址" limitSize:CGSizeMake(SCREEN_WIDTH, 20.f) fontSize:15.f];
    CGFloat width = txtSize.width + 17.f + 6.f;
    [UIView animateWithDuration:0.3f animations:^{
        self.searchInfoView.alpha = 0.02f;
        self.searchInfoView.frame = CGRectMake(0.f, kTopHeight + 44.f, SCREEN_WIDTH, kTopHeight);
        self.keySearchView.frame = CGRectMake(0.f,kTopHeight, SCREEN_WIDTH, 44.f);
        self.searchButton.frame = CGRectMake(SCREEN_WIDTH, 2.f, 60.f, 40.f);
        self.fieldView.frame = CGRectMake(20.f, 7.f, SCREEN_WIDTH - 40.f, 30.f);
        self.searchImgView.frame = CGRectMake((SCREEN_WIDTH - width) / 2.f, (44.f - 17.f) / 2.f, 17.f, 17.f);
        self.searchTextField.frame = CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH-width)) / 2.f + 23.f, 7.f, txtSize.width, 30.f);
        self.btmLineView.alpha = 0.02f;
        self.endSearchBtn.alpha = 0.02f;
//        self.btNavigationBar.frame = CGRectMake(0.f, 0.f, SCREEN_WIDTH, kNavBarHeight);
    } completion:^(BOOL finished) {
        self.isSearch = NO;
        [self changeKeySearchSatus:NO];
        [self.searDataArray removeAllObjects];
        [self.searTableView reloadData];
    }];
}
// YES 抬起 NO 放下
- (void)changeKeySearchSatus:(BOOL)isHidden
{
    self.searchInfoView.hidden = !isHidden;
    self.btmLineView.hidden = !isHidden;
    self.endSearchBtn.hidden = !isHidden;
    self.searchButton.hidden = !isHidden;
    self.findButton.hidden = isHidden;
    if (isHidden) {
        self.endSearchBtn.alpha = 1.f;
        self.btmLineView.alpha = 1.f;
        self.searchInfoView.alpha = 1.f;
    } else {
        self.endSearchBtn.alpha = 0.02f;
        self.btmLineView.alpha = 0.02f;
        self.searchInfoView.alpha = 0.02f;
    }
}
#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellNum = 0;
    if (tableView == _searTableView) {
        cellNum = self.searDataArray.count;
    } else {
        cellNum = self.locAddrArray.count;
    }
    return cellNum;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BtMapAddrTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BtMapAddrTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    AMapPOI *POIInfo;
    if (tableView == self.searTableView) {
        POIInfo = self.searDataArray[indexPath.row];
    } else {
        POIInfo = self.locAddrArray[indexPath.row];
    }
    
    cell.addrLabel.text = POIInfo.name;
    cell.detAddrLabel.text = POIInfo.address;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapPOI *poiPoint;
    if (tableView == self.searTableView) {
        poiPoint = self.searDataArray[indexPath.row];
//        NSLog(@"^^^^^^^^^^^%@%@%@%@%@%@",poiPoint.citycode,poiPoint.pcode,poiPoint.adcode,poiPoint.gridcode,poiPoint.postcode,poiPoint.typecode);
    } else {
        poiPoint = self.locAddrArray[indexPath.row];
//        NSLog(@"^^^^^^^^^^^%@%@%@%@%@%@",poiPoint.citycode,poiPoint.pcode,poiPoint.adcode,poiPoint.gridcode,poiPoint.postcode,poiPoint.typecode);
    }
    NSString *addrStr = [NSString stringWithFormat:@"%@%@%@", poiPoint.district, poiPoint.address, poiPoint.name];
    NSLog(@"------- 2 %f   %f", poiPoint.location.latitude, poiPoint.location.longitude);
    [self selectAddrInfo:addrStr lat:poiPoint.location.latitude lon:poiPoint.location.longitude];
}



- (void)selectAddrInfo:(NSString *)addrStr lat:(CGFloat)latitude lon:(CGFloat)longitude
{
    if (self.locUserAddrBlock) {
        self.locUserAddrBlock(addrStr, latitude, longitude);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}


- (UIView *)noResultView
{
    if (!_noResultView) {
        _noResultView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, 50.f)];
        [_noResultView setBackgroundColor:[UIColor clearColor]];
        [self.searTableView addSubview:_noResultView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 30.f, SCREEN_WIDTH, 20.f)];
        label.text = @"搜索不到该位置";
//        label.textColor = CJHexColor(0x666666, 1.f);
        label.textColor = [networkTool colorWithHexString:@"#cccccc"];
        label.font = [UIFont systemFontOfSize:12.f];
        label.textAlignment = NSTextAlignmentCenter;
        [_noResultView addSubview:label];
        _noResultView.hidden = YES;
    }
    return _noResultView;
}
- (UIView *)unKnowView
{
    if (!_unKnowView) {
        _unKnowView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, 150.f)];
        [_unKnowView setBackgroundColor:[UIColor clearColor]];
        [self.addTableView addSubview:_unKnowView];
        UILabel *unknowLoc = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 20.f, 100.f, 18.f)];
        unknowLoc.text = @"未知位置";
        unknowLoc.font = [UIFont systemFontOfSize:12.f];
        [_unKnowView addSubview:unknowLoc];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20.f, 58.f, SCREEN_WIDTH - 20.f, 0.5f)];
//        [lineView setBackgroundColor:CJHexColor(0xcccccc, 1.f)];
        [_unKnowView addSubview:lineView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 100.f, SCREEN_WIDTH, 20.f)];
        label.text = @"无法定位该地址，请搜索试试。";
//        label.textColor = CJHexColor(0x666666, 1.f);
        label.font = [UIFont systemFontOfSize:12.f];
        label.textAlignment = NSTextAlignmentCenter;
        [_unKnowView addSubview:label];
        _unKnowView.hidden = YES;
    }
    return _unKnowView;
}

- (void)dealloc
{
    self.aMapView = nil;
    self.lockedPointAnno = nil;
    self.aMapSearch = nil;
    self.locManager = nil;
}

@end
