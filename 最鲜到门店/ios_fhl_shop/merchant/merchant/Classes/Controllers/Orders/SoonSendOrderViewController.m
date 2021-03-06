//
//  SoonSendOrderViewController.m
//  merchant
//
//  Created by gs on 14/11/4.
//  Copyright (c) 2014年 JUEWEI. All rights reserved.
//

#import "SoonSendOrderViewController.h"
#import "InputAddressViewController.h"
#import "AreaPickerView.h"
#import "AccountRechargeViewController.h"
#import "HomeViewController.h"
#import "CommonUtils+BaiDUMapMothod.h"
@interface SoonSendOrderViewController ()
@property (strong, nonatomic)NSString* strAddres;//详细地址
@property (strong , nonatomic)AreaPickerView *areaPickerView;
@property (strong, nonatomic)NSString* strDistriCode;//地区编码
@property (assign, nonatomic)BOOL isDianFu;
@property (strong, nonatomic)UITextField* textFieldName;
@property (strong, nonatomic)NSString* strSheng;
@property (strong, nonatomic)NSString* strShi;
@property (strong, nonatomic)NSString* strQu;
@property (strong, nonatomic)UILabel* labelBeiZhu;
@property (assign, nonatomic)BOOL isMobilePhone;//是否应该输入手机号码了
@property (assign, nonatomic)BOOL isNowBilePhone;//输入的为手机号码
@property (assign, nonatomic) int   diList;//区域处在哪个位置
@property (nonatomic,assign) BOOL isJISuButton;//极速发单页面弹出来，区别appleate的定位和本页面调的

@property (assign, nonatomic) CLLocationCoordinate2D strCoordinate2D;//正地理编码
@property (strong, nonatomic)NSString* strDistance;//步行距离
@property (assign, nonatomic) CLLocationCoordinate2D buyerCoordinate2D;//正地理编码
@property (strong, nonatomic)NSString* cityName;
@property (strong, nonatomic)NSString* name;
@end

@implementation SoonSendOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"普通发单";
    //    self.navigationItem.hidesBackButton = YES;
    //    UIBarButtonItem* leftItem = 、[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    //    self.navigationItem.leftBarButtonItem = leftItem;
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发单" style:UIBarButtonItemStyleDone target:self action:@selector(sendBillButtonPressed)];
    self.strDistance = @"";
    self.navigationItem.hidesBackButton = YES;
    //    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setImage:[UIImage imageNamed:@"backWithTitle.png"] forState:UIControlStateNormal];
    //    button.frame = CGRectMake(0, 0, 53, 19);
    
    UIBarButtonItem* rithtBarItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    self.navigationItem.leftBarButtonItem = rithtBarItem ;
    
    
    
    self.isMobilePhone = YES;
    self.isNowBilePhone = YES;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT ) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor colorWithHex:0xf5f5f5];
    //    self.tableView.bounces = NO;
    [self.view addSubview:self.tableView];
    self.isDianFu=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"inPutAddress" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notiTextView) name:UITextViewTextDidChangeNotification object:nil];
  
    
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationNoti) name:LOCATIONNOTI object:nil];//接收到定位的通知
//      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notiTextFieldView:) name:UITextFieldTextDidChangeNotification object:self.textFieldName];
    // Do any additional setup after loading the view from its nib.
}
//-(void)notiTextFieldView:(NSNotification*)noti{
//
//    if ([self.textFieldName isFirstResponder]) {
////        UITextField *textField = (UITextField *)obj.object;
////
////        NSString *toBeString = textField.text;
////        NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
////        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
////            UITextRange *selectedRange = [textField markedTextRange];
////            //获取高亮部分
////            UITextPosition *position = [textFieldpositionFromPosition:selectedRange.start offset:0];
////            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
////            if (!position) {
////                if (toBeString.length ]]> 10) {
////                    textField.text = [toBeString substringToIndex:kMaxLength];
////                }
////            }
////            // 有高亮选择的字符串，则暂不对文字进行统计和限制
////            else{
////
////            }
////        }
////        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
////        else{
////            if (toBeString.length ]]> kMaxLength) {
////                textField.text = [toBeString substringToIndex:kMaxLength];
////            }
////        }
//    }
//
//}
-(void)notiTextView{
    FLDDLogDebug(@"%@",self.textViewBeiZhu.text);
    if (self.textViewBeiZhu.text.length==0) {
        self.labelBeiZhu.hidden = NO;
    }else{
        self.labelBeiZhu.hidden = YES;
        
    }
}
-(void)noti:(NSNotification*)noti{
    FLDDLogDebug(@"(NSNotification*)noti");
    if ([[noti.userInfo valueForKey:@"inPutAddress"] isEqualToString:@"cancel"]) {
//        self.textFieldAddressedDetail.placeholder =@"请输入详细地址";
        return;
    }
    
    self.textFieldAddressedDetail.text = [noti.userInfo valueForKey:@"inPutAddress"];
    CLLocationCoordinate2D coor2D;
    coor2D.latitude =[[noti.userInfo valueForKey:@"latitude"] floatValue];
      coor2D.longitude =[[noti.userInfo valueForKey:@"longitude"] floatValue];
    
    _buyerCoordinate2D = coor2D;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    BMKPlanNode* nodeStart =[CommonUtils  comBaiDu_BMKPlanNodeWithCityName:nil withAddr:nil withCoor2D:CLLocationCoordinate2DMake([[noti.userInfo valueForKey:@"latitude"] floatValue], [[noti.userInfo valueForKey:@"longitude"] floatValue])];
     BMKPlanNode* nodeEnd =[CommonUtils  comBaiDu_BMKPlanNodeWithCityName:nil withAddr:nil withCoor2D:CLLocationCoordinate2DMake([SelfUser currentSelfUser].mddyAdderssedLocationcoorDinate2D.latitude, [SelfUser currentSelfUser].mddyAdderssedLocationcoorDinate2D.longitude)];
    [CommonUtils comBaiDu_DistanceInfoWithNodeStaty:nodeStart withNodeEnd:nodeEnd withTagget:self withBlock:^(BOOL isSuccess) {
        
    }];
    
//    //初始化检索对象
//    _searcher =[[BMKGeoCodeSearch alloc]init];
//    _searcher.delegate = self;
//    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
//    geoCodeSearchOption.city= [noti.userInfo valueForKey:@"detailAdder"];
//    geoCodeSearchOption.address = [noti.userInfo valueForKey:@"shiName"];
//    BOOL flag = [_searcher geoCode:geoCodeSearchOption];
//
//    if(flag)
//    {
//        NSLog(@"geo检索发送成功");
//    }
//    else
//    {
//        NSLog(@"geo检索发送失败");
//    }
//    FLDDLogDebug(@"latitude:%f, longitude:%f, cityName:%@, name:%@", [SelfUser currentSelfUser].mddyAdderssedLocationcoorDinate2D.latitude, [SelfUser currentSelfUser].mddyAdderssedLocationcoorDinate2D.longitude, [noti.userInfo valueForKey:@"shiName"], [noti.userInfo valueForKey:@"detailAdder"]);
//    _cityName = [noti.userInfo valueForKey:@"shiName"];
//    _name = [noti.userInfo valueForKey:@"detailAdder"];
//    [self distanceInfoWithcityName:_cityName withName:_name];
    
}
//- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
//    if (error == BMK_SEARCH_NO_ERROR) {
//        //在此处理正常结果
//   
//        self.strCoordinate2D = result.location;
//    }
//    else {
//        NSLog(@"抱歉，未找到结果");
//    }
//}

//-(void)distanceInfoWithcityName:(NSString*)cityName withName:(NSString*)name{
//    if (!self.routeSearch) {
//        self.routeSearch = [[BMKRouteSearch alloc] init];
//        self.routeSearch.delegate = self;
//    }
//    
//    
//    BMKPlanNode *start = [[BMKPlanNode alloc] init];
//    CLLocationCoordinate2D cloStart;
//    cloStart.latitude = [SelfUser currentSelfUser].mddyAdderssedLocationcoorDinate2D.latitude;
//    cloStart.longitude = [SelfUser currentSelfUser].mddyAdderssedLocationcoorDinate2D.longitude;
////    cloStart.longitude = 120.150752;
////    cloStart.latitude = 30.277678;
//    start.pt = cloStart;
//
//    
//    BMKPlanNode *end = [[BMKPlanNode alloc] init];
//
//    end.cityName =cityName;
//    end.name = name;
//    
//    BMKWalkingRoutePlanOption *walkingRoutePlanOption = [[BMKWalkingRoutePlanOption alloc] init];
//    walkingRoutePlanOption.from = start;
//    walkingRoutePlanOption.to = end;
//    FLDDLogDebug(@"distanceInfoWithcityName");
//    FLDDLogDebug(@"latitude:%f, longitude:%f, cityName:%@, name:%@", cloStart.latitude, cloStart.longitude, cityName, name);
//    
//    BOOL flg = [self.routeSearch walkingSearch:walkingRoutePlanOption];
//    
//    if (flg) {
//        FLDDLogDebug(@"success");
//    }
//    else {
//        FLDDLogInfo(@"failed");
//    }
//    walkingRoutePlanOption = nil;
//    end = nil;
//    start= nil;
//    
//}
#pragma mark -BMKRouteSearchDelegate

- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher result:(BMKWalkingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == BMK_SEARCH_NO_ERROR) {
        
        BMKWalkingRouteLine *walkingLine = (BMKWalkingRouteLine *)[result.routes objectAtIndex:0];
//        NSString* distance=[NSString stringWithFormat:@"%d",walkingLine.distance];
        FLDDLogDebug(@"distance:%d, 买家地址：%@", walkingLine.distance, walkingLine.terminal.title);
        
        self.strDistance = [NSString stringWithFormat:@"%d",walkingLine.distance ];
//        BMKGeoCodeSearch *geoCodeSearch =[[BMKGeoCodeSearch alloc]init];//必须将BMKGeoCodeSearch的创建放在这里面，因为不用他的时候，他自动销毁了。内容也会覆盖。如果放在外面创建，那么地理编码永远都只会得到最后一个
//        //实现委托
//        geoCodeSearch.delegate = self;
////        //设置城市
////        citys=[result.cityList objectAtIndex:i];
////        //设置详细地址信息
////        addresses=[NSString stringWithFormat:@"%@%@",[result.districtList objectAtIndex:i],[result.keyList objectAtIndex:i]];
//        //创建地理编码的Option对象
//        BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
//        //设置地理编码参数
//        geoCodeSearchOption.city= walkingLine.terminal.title;
//        geoCodeSearchOption.address = walkingLine.terminal.title;
////        geoCodeSearchOption.city= _cityName;
////        geoCodeSearchOption.address = _name;
//        //获取是否成功
//        BOOL flag = [geoCodeSearch geoCode:geoCodeSearchOption];
//        if(flag)
//        {
//            FLDDLogDebug(@"geo检索发送成功。 city: %@, address:%@.",geoCodeSearchOption.city, geoCodeSearchOption.address);
//        }
//        else
//        {
//            FLDDLogDebug(@"geo检索发送失败");
//        }
    }
    else
    {
          [MBProgressHUD hudShowWithStatus :self : @"步行距离出错"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDDENMBProgressHUD" object:self userInfo:@{@"analyzeResult":@"fail"}];
    }
    
    
}
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR)
    {
        FLDDLogDebug(@"latitude:%f, longitude:%f", result.location.latitude, result.location.longitude);
        _buyerCoordinate2D = result.location;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDDENMBProgressHUD" object:self userInfo:@{@"analyzeResult":@"success"}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDDENMBProgressHUD" object:self userInfo:@{@"analyzeResult":@"fail"}];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) {
        return 4;
    }else{
        return 3;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strINTI = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strINTI];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strINTI];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row ==0) {
            
            
            
            
            static NSString* strINTI1 = @"cell1";
            UITableViewCell* cell1 = [tableView dequeueReusableCellWithIdentifier:strINTI1];
            if (!cell1) {
                cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strINTI1];
            }
            
            
            
            if (self.textFieldPhoneNumber == nil) {
                
                self.labelFuHao = [[UILabel alloc]initWithFrame:CGRectMake(183, 0, 20, 44)];
                self.labelFuHao.text = @"－";
                self.labelFuHao.hidden = YES;
                [cell1 addSubview: self.labelFuHao];
                
                self.textFieldPhoneNumber = [[UITextField alloc]initWithFrame:CGRectMake((iPhone6Plus?:0)+110, 0, 180, 44)];
                self.textFieldPhoneNumber.delegate =self;
                self.textFieldPhoneNumber.font = [UIFont systemFontOfSize:16];
                self.textFieldPhoneNumber.placeholder = @"请输入手机号码";
                self.textFieldPhoneNumber.keyboardType =  UIKeyboardTypeNumberPad;
                [cell1.contentView addSubview:self.textFieldPhoneNumber];
                
                
                //                self.textFenJi = [[UITextField alloc]initWithFrame:CGRectMake(199, 0, 180, 44)];
                //                self.textFenJi.delegate =self;
                //                self.textFenJi.placeholder = @"分机";
                //                self.textFenJi.hidden = YES;
                //                self.textFenJi.keyboardType =  UIKeyboardTypeNumberPad;
                //                [cell1.contentView addSubview:self.textFenJi];
                
                self.buttonInputTEL =[UIButton buttonWithType:UIButtonTypeCustom];
                self.buttonInputTEL.frame = CGRectMake(WINDOW_WIDTH-90, 0, 90, 44);
                
                self.buttonInputTEL.titleLabel.textAlignment = NSTextAlignmentLeft;
                [self.buttonInputTEL setTitleColor:[UIColor colorWithHex:0x007aff] forState:UIControlStateNormal];
//                self.buttonInputTEL.font = [UIFont systemFontOfSize:16];
                self.buttonInputTEL.titleLabel.font = [UIFont systemFontOfSize:16];
                self.buttonInputTEL.tag = 100;
                [self.buttonInputTEL setTitle:@"切换至座机" forState:UIControlStateNormal];
                [self.buttonInputTEL addTarget:self action:@selector(inputTEL) forControlEvents:UIControlEventTouchUpInside];
                
                [cell1.contentView addSubview:self.buttonInputTEL];
                
                self.sysPhoneNumber = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 0, 180, 44)];
                self.sysPhoneNumber.text = @"手机号码";
                self.sysPhoneNumber.font = [UIFont systemFontOfSize:16];
                
                self.textFiledQuHao = [[UITextField alloc]initWithFrame:CGRectMake(63, 0, 60, 44)];
                self.textFiledQuHao.text = [SelfUser currentSelfUser].strQuHaoTEL;
                self.textFiledQuHao.hidden = YES;
                self.textFiledQuHao.font = [UIFont systemFontOfSize:16];
                self.textFiledQuHao.keyboardType =  UIKeyboardTypeNumberPad;
                self.textFiledQuHao.delegate =self;
                [cell1.contentView addSubview:self.textFiledQuHao];
                
                self.labelFuHao = [[UILabel alloc]initWithFrame:CGRectMake(96, 0, 20, 44)];
                self.labelFuHao.text = @"－";
                self.labelFuHao.hidden = YES;
                [cell1 addSubview: self.labelFuHao];
                
                
                //                self.labelFuHao1 = [[UILabel alloc]initWithFrame:CGRectMake(183, 0, 20, 44)];
                //                self.labelFuHao1.text = @"－";
                ////                self.labelFuHao1.hidden = YES;
                //                [cell1 addSubview: self.labelFuHao1];
                
                
                [cell1.contentView addSubview:self.sysPhoneNumber];
            }
            
            
            //            if (self.textFieldPhoneNumber == nil) {
            //
            //                self.labelFuHao = [[UILabel alloc]initWithFrame:CGRectMake(183, 0, 20, 44)];
            //                self.labelFuHao.text = @"－";
            //                self.labelFuHao.hidden = YES;
            //                [cell1 addSubview: self.labelFuHao];
            //
            //            self.textFieldPhoneNumber = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, 180, 44)];
            //            self.textFieldPhoneNumber.delegate =self;
            //                        self.textFieldPhoneNumber.placeholder = @"请输入手机号码";
            //            self.textFieldPhoneNumber.keyboardType =  UIKeyboardTypeNumberPad;
            //            [cell1.contentView addSubview:self.textFieldPhoneNumber];
            //
            //
            //            self.textFenJi = [[UITextField alloc]initWithFrame:CGRectMake(200, 0, 180, 44)];
            //            self.textFenJi.delegate =self;
            //            self.textFenJi.placeholder = @"分机";
            //                self.textFenJi.hidden = YES;
            //            self.textFenJi.keyboardType =  UIKeyboardTypeNumberPad;
            //            [cell1.contentView addSubview:self.textFenJi];
            //
            //            self.buttonInputTEL =[UIButton buttonWithType:UIButtonTypeCustom];
            //            self.buttonInputTEL.frame = CGRectMake(WINDOW_WIDTH-90, 0, 90, 44);
            //
            //            self.buttonInputTEL.titleLabel.textAlignment = NSTextAlignmentLeft;
            //            [self.buttonInputTEL setTitleColor:UICOLOR(131, 185, 65, 1) forState:UIControlStateNormal];
            //            self.buttonInputTEL.font = [UIFont systemFontOfSize:16];
            //                self.buttonInputTEL.tag = 100;
            //                 [self.buttonInputTEL setTitle:@"填写座机" forState:UIControlStateNormal];
            //            [self.buttonInputTEL addTarget:self action:@selector(inputTEL) forControlEvents:UIControlEventTouchUpInside];
            //
            //            [cell1.contentView addSubview:self.buttonInputTEL];
            //
            //            self.sysPhoneNumber = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 180, 44)];
            //            self.sysPhoneNumber.text = @"手机号码";
            //            self.sysPhoneNumber.font = [UIFont systemFontOfSize:16];
            //            [cell1.contentView addSubview:self.sysPhoneNumber];
            //            }
            cell = cell1;
            
        }else if (indexPath.row == 1){
            
            static NSString* strINTI2 = @"cell2";
            UITableViewCell* cell2 = [tableView dequeueReusableCellWithIdentifier:strINTI2];
            if (!cell2) {
                cell2 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strINTI2];
            }
            
            if (self.sysName == nil) {
                self.sysName = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 0, 180, 44)];
                self.sysName.text = @"姓       名";
                self.sysName.font = [UIFont systemFontOfSize:16];
                [cell2.contentView addSubview:self.sysName];
                
                
                
                self.textFieldName = [[UITextField alloc]initWithFrame:CGRectMake((iPhone6Plus?:0)+110, 0, 300, 44)];
                self.textFieldName.placeholder = @"请输入姓名(可选)";
                self.textFieldName.delegate =self;
                   self.textFieldName.returnKeyType = UIReturnKeyDone;
                self.textFieldName.font = [UIFont systemFontOfSize:16];
                [cell2.contentView addSubview:self.textFieldName];
            }
            cell = cell2;
            
        }
        //            else if (indexPath.row == 2){
        //
        //            static NSString* strINTI3 = @"cell3";
        //            UITableViewCell* cell3 = [tableView dequeueReusableCellWithIdentifier:strINTI3];
        //            if (!cell3) {
        //                cell3 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strINTI3];
        //            }
        //
        //            if (self.sysAddress == nil) {
        //
        //
        //                self.sysAddress = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 180, 44)];
        //
        //                self.areaPickerView = [[AreaPickerView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)];
        //                //        FLDDLogDebug(@"%@",[self.areaPickerView districts]);
        //                int diList=0;
        //                for (NSDictionary* dict in [self.areaPickerView districts]) {
        //                    diList++;
        //                    if ([[dict valueForKey:@"districtCode" ]isEqualToString:[SelfUser currentSelfUser].countyCode]) {
        //                        //                        FLDDLogDebug(@"%@",[dict valueForKey:@"districtName" ]);
        //                        self.sysAddress.text  =[dict valueForKey:@"districtName" ];
        //                        self.strQu =self.sysAddress.text;
        //                        self.strDistriCode =[SelfUser currentSelfUser].countyCode;
        //                        FLDDLogDebug(@"%@",self.strDistriCode);
        //                        break;
        //                    }
        //                }
        //
        //                self.diList = diList-1;
        //
        //                //            self.sysAddress.text = @"西湖区";
        //                self.sysAddress.font = [UIFont systemFontOfSize:16];
        //                [cell3 addSubview:self.sysAddress];
        //
        //                self.buttonArea = [UIButton buttonWithType:UIButtonTypeCustom];
        //                self.buttonArea.frame =   CGRectMake(WINDOW_WIDTH-44, 0, 44, 44);
        //                [self.buttonArea setImage:[UIImage imageNamed:@"xiala.png"] forState:UIControlStateNormal];
        //                self.buttonArea.tag = indexPath.section;
        //                [self.buttonArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        //                [cell3 addSubview:self.buttonArea];
        //            }
        //            cell = cell3;
        //
        //
        //        }
        else if(indexPath.row==2){
            
            static NSString* strINTI4 = @"cell4";
            UITableViewCell* cell4 = [tableView dequeueReusableCellWithIdentifier:strINTI4];
            if (!cell4) {
                cell4 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strINTI4];
            }
            
            UILabel* labelAddr = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 0, 180, 44)];
            labelAddr.text = @"详细地址";
            labelAddr.font = [UIFont systemFontOfSize:16];
            [cell4.contentView addSubview:labelAddr];
            
            
            if (self.textFieldAddressedDetail == nil) {
//                self.textFieldAddressedDetail = [[UITextField alloc]initWithFrame:CGRectMake((iPhone6Plus?:0)+110, 0, WINDOW_WIDTH-20, 44)];
//                self.textFieldAddressedDetail.placeholder = @"输入小区、写字楼、街道等";
//                self.textFieldAddressedDetail.enabled = NO;
//                self.textFieldAddressedDetail.font = [UIFont systemFontOfSize:16];
//                
//                [cell4 addSubview:self.textFieldAddressedDetail];
                
            }
            if (self.textFieldAddressedDetail.text.length==0) {
                self.textFieldAddressedDetail.text = @"输入小区、写字楼、街道等";
            }
            self.textFieldAddressedDetail = [CommonUtils commonMoreLabelWithText:self.textFieldAddressedDetail.text withFontSize:16 withBoundsWide:WINDOW_WIDTH-110 withOriginX:110 withOriginY:labelAddr.center.y-10];
            [cell4 addSubview:self.textFieldAddressedDetail];
              self.textFieldAddressedDetail.alpha = 1;
            if ([self.textFieldAddressedDetail.text isEqualToString:@"输入小区、写字楼、街道等"]) {
                self.textFieldAddressedDetail.textColor =[UIColor lightGrayColor];
                self.textFieldAddressedDetail.alpha = 0.7;
            }
            NSInteger height =self.textFieldAddressedDetail.frameHeight;
            
            cell4.frame = CGRectMake(cell4.frameX, cell4.frameY, WINDOW_WIDTH, (ceilf(height/44)+1)*44);
            self.textFieldAddressedDetail.center = CGPointMake(self.textFieldAddressedDetail.center.x, cell4.center.y);
            
            
            cell = cell4;
        }else{
            
            static NSString* strINTI4 = @"cell5";
            UITableViewCell* cell5 = [tableView dequeueReusableCellWithIdentifier:strINTI4];
            if (!cell5) {
                cell5 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strINTI4];
            }
            
            
            if (self.textViewAddressedDetail == nil) {
                self.textViewAddressedDetail = [[UITextField alloc]initWithFrame:CGRectMake((iPhone6Plus?:0)+110, 0, WINDOW_WIDTH-110, 44)];
                self.textViewAddressedDetail.placeholder = @"输入楼层、门牌号等（可选）";
                   self.textViewAddressedDetail.returnKeyType = UIReturnKeyDone;
                self.textViewAddressedDetail.delegate = self;
                self.textViewAddressedDetail.font = [UIFont systemFontOfSize:16];
                [cell5 addSubview:self.textViewAddressedDetail];
                
            }
            
            cell = cell5;

        }
    }else{
        if (indexPath.row ==0) {
            
            self.sysDianFu = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 0, 180, 44)];
            self.sysDianFu.text = @"是否需要配送员垫付";
            self.sysDianFu.font = [UIFont systemFontOfSize:16];
            [cell addSubview:self.sysDianFu];
            
            
            self.buttonDianFu = [UIButton buttonWithType:UIButtonTypeCustom];
            self.buttonDianFu.frame =   CGRectMake(WINDOW_WIDTH-124, 0, 124, 44);
            self.buttonDianFu.tag = indexPath.section;
            
            [self.buttonDianFu addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonDianFu setImage:[UIImage imageNamed:@"switch_judge_left.png"] forState:UIControlStateNormal];
            [cell addSubview:self.buttonDianFu];
            
        }else if (indexPath.row == 1){
            
            self.sysJinE = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 0, 180, 44)];
            self.sysJinE.text = @"订单金额";
            self.sysJinE.font = [UIFont systemFontOfSize:16];
            [cell addSubview:self.sysJinE];
            
            self.textFieldJinE = [[UITextField alloc]initWithFrame:CGRectMake(110, 0, 180, 44)];
            self.textFieldJinE.placeholder = @"请输入订单金额(元)";
            self.textFieldJinE.delegate = self;
            self.textFieldJinE.font = [UIFont systemFontOfSize:16];
            self.textFieldJinE.keyboardType = UIKeyboardTypeDecimalPad;
            [cell addSubview:self.textFieldJinE];
            
            
        }else{
            self.textViewBeiZhu = [[UITextView alloc]initWithFrame:CGRectMake(15, 0, WINDOW_WIDTH-30, 80)];
            //            self.textViewBeiZhu.text = @"备注: ";
            self.textViewBeiZhu.delegate = self;
            self.textViewBeiZhu.returnKeyType =UIReturnKeyDone;
            self.textViewBeiZhu.font = [UIFont systemFontOfSize:16];
            self.textViewBeiZhu.delegate = self;
            self.textViewBeiZhu.textColor = [UIColor darkGrayColor];
            [cell addSubview:self.textViewBeiZhu];
            
            self.labelBeiZhu =[[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+4:0)+3, 2, 100, 30)];
            self.labelBeiZhu.text = @"备注(可选)";
            //            self.labelBeiZhu.textAlignment = NSWritingDirectionRightToLeft;
            self.labelBeiZhu.font =[UIFont systemFontOfSize:15.4];
            self.labelBeiZhu.textColor = [UIColor lightGrayColor];
            [self.textViewBeiZhu addSubview:self.labelBeiZhu];
            
            
            
            
        }
        
        
    }
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            return 80*1;
        }else{
            return 44;
        }
    }else{
        if (indexPath.row==2) {
            
        UITableViewCell* cell =[self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            
        return cell.frameHeight;
        }
        return 44;
    }
    return 0;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        InputAddressViewController* inputAdd = [[InputAddressViewController alloc ]initWithNibName:nil bundle:nil];
        if (![self.textFieldAddressedDetail.text isEqualToString:@"输入小区、写字楼、街道等"]) {
                inputAdd.strCityName =   self.textFieldAddressedDetail.text;
        }
   
        [self.navigationController pushViewController:inputAdd animated:YES];
        
        
        return;
    }
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 150;
    }
    
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIControl* view = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, 44)];
    if (section==0) {
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 12, 100, 30)];
        label.text = @"收货人信息";
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
    }else{
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake((iPhone6Plus?+5:0)+15, 12, 100, 30)];
        label.text = @"订单信息";
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
        
    }
    [view addTarget:self action:@selector(resignFirstResponder1) forControlEvents:UIControlEventTouchDown];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, 150)];
    
    if (section == 1) {
        UIButton* buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonCancel addTarget:self action:@selector(sendBillButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [buttonCancel setTitle:@"确认发单" forState:UIControlStateNormal];
        float red = 252/255.0;
        float green = 102/255.0;
        float blue = 5/255.0;
        [buttonCancel setBackgroundColor: [UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
        buttonCancel.layer.cornerRadius = 3;
        buttonCancel.frame = CGRectMake(16, 10, WINDOW_WIDTH-32, 44);
        [view addSubview:buttonCancel];
        
    }
    
    return view;
}



-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)buttonPressed:(UIButton*)sender
{
    UIButton* button = sender;
    FLDDLogDebug(@"%ld",(long)button.tag);
    if (button.tag == 0) {
        [self.textFieldJinE resignFirstResponder];
        [self.textFieldPhoneNumber resignFirstResponder];
        [self.textFieldName resignFirstResponder  ];
        [self.textViewBeiZhu resignFirstResponder];
        
        
        
    }else{
        
    }
}


#pragma mark pickViewDatacourse
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 3;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    if (textField == self.textFieldPhoneNumber) {
        
        if (self.isNowBilePhone) {
            
            self.textFenJi.text  =@"";
            
            if (textField.text.length<=13) {
                
                if (textField.text.length == 13) {
                    if ([string isEqualToString:@""]) {
                        
                        return YES;
                    }else{
                        //                        [SVProgressHUD showErrorWithStatus:@"手机号位数超过限制"];
                        return NO;
                    }
                }
                return [CGeneralFunction inputTelephone: textField : range : string];
                return YES;
            }else{
                //                [SVProgressHUD showErrorWithStatus:@"手机号位数超过限制"];
                return NO;
            }
        }else{
            if (textField.text.length == 8) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                textField.text = [textField.text stringByAppendingFormat:@"-"];
                return YES;
            }
            if (textField.text.length == 10) {
                if ([string isEqualToString:@""]) {
                    textField.text =[textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    
                    return YES;
                }
            }
            if (textField.text.length>12) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return NO;
            }
            
   
        }
  
    }
    if (textField == self.textFiledQuHao) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
        NSString* str = [textField.text stringByAppendingString:string];
        
        if ([str isEqualToString:@"010"] || [str isEqualToString:@"020"]|| [str isEqualToString:@"021"]|| [str isEqualToString:@"022"]|| [str isEqualToString:@"023"]|| [str isEqualToString:@"024"]|| [str isEqualToString:@"025"]|| [str isEqualToString:@"027"]|| [str isEqualToString:@"028"]|| [str isEqualToString:@"029"]) {
            if (![string isEqualToString:@""]) {
                
                textField.text = [textField.text stringByAppendingString:string];
                [self.textFieldPhoneNumber becomeFirstResponder];
                
                return NO;
            }
        }
        
        if ([textField.text isEqualToString:@"010"] || [textField.text isEqualToString:@"020"]|| [textField.text isEqualToString:@"021"]|| [textField.text isEqualToString:@"022"]|| [textField.text isEqualToString:@"023"]|| [textField.text isEqualToString:@"024"]|| [textField.text isEqualToString:@"025"]|| [textField.text isEqualToString:@"027"]|| [textField.text isEqualToString:@"028"]|| [textField.text isEqualToString:@"029"]) {
            if (textField.text.length >2) {
                //                textField.text = [textField.text stringByAppendingString:string];
                [self.textFieldPhoneNumber becomeFirstResponder];
                
                return YES;
            }
        }
        
        if (textField.text.length==3) {
            if (![string isEqualToString:@""]) {
                textField.text = [textField.text stringByAppendingString:string];
                [self.textFieldPhoneNumber becomeFirstResponder];
                return NO;
                
            }
        }
        if (textField.text.length ==1) {
            if ([string isEqualToString:@""]) {
                self.textFiledQuHao.placeholder  = @"区号";
                return YES;
            }
        }
        
        if (textField.text.length >3) {
            if (![string isEqualToString:@""]) {
                return NO;
            }
        }
    }
    if (textField == self.textFieldName) {
        if ([string isEqualToString:@"\n"])
        {
            [self.view endEditing:YES];
            
        }
        
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        
    
        if (textField.text.length + string.length <=10) {
            
          
            if ([string isEqualToString:@"➋"]||[string isEqualToString:@"➌"]||[string isEqualToString:@"➍"]||[string isEqualToString:@"➎"]||[string isEqualToString:@"➏"]||[string isEqualToString:@"➐"]||[string isEqualToString:@"➑"]||[string isEqualToString:@"➒"]) {
                return YES;
                
            }
            if ([string isEqualToString:@"➋"]||[string isEqualToString:@"➌"]||[string isEqualToString:@"➍"]||[string isEqualToString:@"➎"]||[string isEqualToString:@"➏"]||[string isEqualToString:@"➐"]||[string isEqualToString:@"➑"]||[string isEqualToString:@"➒"]) {
                return YES;
                
            }
            if ([self checkName:string]) {
                return YES;
            }else{
                return NO;
            }
        }else{
            //            [SVProgressHUD showErrorWithStatus:@"姓名长度2-10位"];
            [MBProgressHUD hudShowWithStatus:self :@"姓名长度2-10位"];
            return NO;
        }
    }
    if (textField ==self.textFieldJinE) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        if ([CommonUtils checkNumber:string WithTextFieldText:textField.text]) {
            if ([textField.text rangeOfString:@"."].length!=0) {
                if ([textField.text substringToIndex:[textField.text rangeOfString:@"."].location -1].length<=3) {
                    if ([textField.text substringFromIndex:[textField.text rangeOfString:@"."].location].length <=2) {
                        
                        return YES;
                    }else{
                        return NO;
                    }
                    
                }else{
                    return NO;
                }
            }else{
                
                if ([string isEqualToString:@"."]) {
                    if(textField.text.length == 0){
                        return NO;
                    }
                    return YES;
                }else{
                    if (textField.text.length <=3) {
                        return YES;
                    }else{
                        return NO;
                    }
                }
            }
            
        }
        return NO;
        
        //    [SVProgressHUD showErrorWithStatus:@"请输入正确金额"];
        
    }
    
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    if (textField == self.textFieldJinE|| textField == self.textFieldName||textField==self.textViewAddressedDetail) {
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect = CGRectMake(0.0f, 64, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = rect;
        [UIView commitAnimations];
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textFieldJinE ) {
        
        
        
        CGRect frame = textField.frame;
        int offset = frame.origin.y + 32 - (self.view.frame.size.height - 495);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        if(offset > 0)
        {
            CGRect rect = CGRectMake(0.0f, -offset,width,height);
            self.view.frame = rect;
        }
        [UIView commitAnimations];
    }
    
    
    if (iPhone4) {
//        if (textField == self.textFieldAddressedDetail ) {
//            
//            
//            
//            CGRect frame = textField.frame;
//            int offset = frame.origin.y + 32 - (self.view.frame.size.height - 495);//键盘高度216
//            NSTimeInterval animationDuration = 0.30f;
//            [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
//            [UIView setAnimationDuration:animationDuration];
//            float width = self.view.frame.size.width;
//            float height = self.view.frame.size.height;
//            if(offset > 0)
//            {
//                CGRect rect = CGRectMake(0.0f, -offset,width,height);
//                self.view.frame = rect;
//            }
//            [UIView commitAnimations];
//        }
        
    }
    
    if (textField== self.textViewAddressedDetail) {
        CGRect frame = textField.frame;
        int offset = frame.origin.y + 32 - (self.view.frame.size.height - 495);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        if(offset > 0)
        {
            CGRect rect = CGRectMake(0.0f, -offset,width,height);
            self.view.frame = rect;
        }
        [UIView commitAnimations];

    }
    
}




- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.textViewBeiZhu) {
        
        
        
        CGRect frame = textView.frame;
        int offset = frame.origin.y + 32 - (self.view.frame.size.height - 575);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        if(offset > 0)
        {
            CGRect rect = CGRectMake(0.0f, -offset,width,height);
            self.view.frame = rect;
        }
        [UIView commitAnimations];
    }
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"])
    {
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect = CGRectMake(0.0f, 64, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = rect;
        [UIView commitAnimations];
        
        [textView resignFirstResponder];
        return NO;
    }
    
    ////    FLDDLogDebug(@"%@",text);
    if (self.textViewBeiZhu.text.length==0){//textview长度为0
        if ([text isEqualToString:@""]) {//判断是否为删除键
            self.labelBeiZhu.hidden=NO;//隐藏文字
        }else{
            self.labelBeiZhu.hidden=YES;
        }
        
    }else{//textview长度不为0
        if (self.textViewBeiZhu.text.length==1){//textview长度为1时候
            if ([text isEqualToString:@""]) {//判断是否为删除键
                self.labelBeiZhu.hidden=NO;
            }else{//不是删除
                self.labelBeiZhu.hidden=YES;
            }
        }else{//长度不为1时候
            self.labelBeiZhu.hidden=YES;
        }
    }
    //
    //
    //    return YES;
    
    NSString *string = textView.text;
    
    //    if (text.length+string.length >= INPUT_LENGTH_LIMIT+1 ) {
    //        if (string.length == 0) {
    //            self.labelBeiZhu.hidden=NO;
    //        }
    //        return NO;
    //
    //    }
    if (string.length >= INPUT_LENGTH_LIMIT && text.length >= 1) {
        return NO;
    }
    
    if (string.length + text.length == INPUT_LENGTH_LIMIT + 1 && text.length > 0) {
        return NO;
    }
    else {
        //        self.text = textView.text;
    }
    if ([text isEqualToString:@""])
    {
        return YES;
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    
 
    
    NSString *string = textView.text;
    if (textView.text.length <= INPUT_LENGTH_LIMIT) {
        //        self.text = textView.text;
    }
    else {
        
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (string.length > INPUT_LENGTH_LIMIT) {
                textView.text = [string substringToIndex:INPUT_LENGTH_LIMIT];
            }
        }
        //        self.textView.text = [textView.text substringToIndex:INPUT_LIMIT];
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)resignFirstResponder1{
    
    [self.textFieldJinE resignFirstResponder];
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.textFieldName resignFirstResponder];
    [self.textViewBeiZhu resignFirstResponder];
    [self.textViewAddressedDetail resignFirstResponder];
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 64-80+64, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.textFieldJinE resignFirstResponder];
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.textFieldName resignFirstResponder];
    [self.textViewBeiZhu resignFirstResponder];
    [self.textViewAddressedDetail resignFirstResponder];
      _searcher.delegate = nil;
    
}
-(void)switchPressed:(UIButton*)sender
{
    UIButton* button = sender;
    if (button.tag) {
        [button setImage: [UIImage imageNamed:@"switch_judge_right.png"] forState:UIControlStateNormal];
        self.isDianFu = NO;
    }else{
        [button setImage: [UIImage imageNamed:@"switch_judge_left.png"] forState:UIControlStateNormal];
        self.isDianFu = YES;
    }
    button.tag = !button.tag;
}
-(void)sendBillButtonPressed{
    
    if (![CLLocationManager locationServicesEnabled]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位服务当前可能尚未打开，请在设置中打开！" message:nil delegate:nil cancelButtonTitle:@"确定"otherButtonTitles: nil];
        
        [alertView show];
        return;
        
    }else{
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否授权最鲜到门店使用GPS定位服务" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            alertView.tag =111;
            [alertView show];
            
            return;
        }
        
        
        
    }
    
    
    //    [AppManager setUserDefaultsValue:latitude key:@"latitude"];
    //    [AppManager setUserDefaultsValue:longitude key:@"longitude"];
    
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate locationDingWei];
    self.isJISuButton = YES;

    
      [SelfUser hudShowWithViewcontroller:self];
    
    
    
    
    
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 111) {
        if (buttonIndex == 1) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }

    }
    else if (alertView.tag == 1888) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            AccountRechargeViewController * messagesViewController = [[AccountRechargeViewController alloc ]initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:messagesViewController animated:YES];
        }
    }
    
    else{
    
    if (buttonIndex == 1) {
        
        FLDDLogDebug(@"%@",self.textFieldJinE.text);
        
        NSString* strDianFU = nil;
        if ( self.isDianFu) {
            strDianFU = @"2";//需要
        }else{
            strDianFU = @"1";
        }
        //        NSString* strBeiZhu = nil;
        //        if (self.textViewBeiZhu.text.length>3) {
        //            strBeiZhu = [self.textViewBeiZhu.text substringFromIndex:3];
        //            FLDDLogDebug(@"%@",strBeiZhu);
        //        }else{
        //            strBeiZhu = @"";
        //        }
        //         FLDDLogDebug(@"%@",strBeiZhu);
        FLDDLogDebug(@"%@",self.textFieldPhoneNumber.text);
        FLDDLogDebug(@"%@",self.textFieldName.text);
        FLDDLogDebug(@"%@",self.strDistriCode);
        FLDDLogDebug(@"%@",self.textFieldAddressedDetail.text);
        FLDDLogDebug(@"!!!!%@",strDianFU);
        FLDDLogDebug(@"%@",self.textViewBeiZhu.text);
        NSDictionary *params=nil;
        NSLog(@"%f---%f",_buyerCoordinate2D.longitude,_buyerCoordinate2D.latitude);
        
        
        if (self.isNowBilePhone) {
            
            params = @{@"addressDetail":self.textViewAddressedDetail.text,@"walkingDistance":self.strDistance,@"consigneeLongitude":[NSString stringWithFormat:@"%f",_buyerCoordinate2D.longitude],@"consigneeLatitude":[NSString stringWithFormat:@"%f",_buyerCoordinate2D.latitude],@"consigneeTel":self.textFieldPhoneNumber.text,@"consigneeName":self.textFieldName.text ,@"consigneeCountyCode":@"",@"address":self.textFieldAddressedDetail.text,@"isPaidAdvance":strDianFU,@"waybillPrice":[NSString stringWithFormat:@"%.0f",[self.textFieldJinE.text floatValue]*100],@"content":self.textViewBeiZhu.text,@"cmdCode":g_sendWaybillCmd,@"sendWaybillClerkLatitude":[AppManager valueForKey:@"latitude"],@"sendWaybillClerkLongitude":[AppManager valueForKey:@"longitude"]};
        }else{
            //            if (self.textFenJi.text.length >0) {
            
            
            
            params = @{@"addressDetail":self.textViewAddressedDetail.text,@"walkingDistance":self.strDistance,@"consigneeLongitude":[NSString stringWithFormat:@"%.f",_buyerCoordinate2D.longitude],@"consigneeLatitude":[NSString stringWithFormat:@"%.f",_buyerCoordinate2D.latitude],@"consigneeTel":[NSString stringWithFormat:@"%@-%@",self.textFiledQuHao.text,self.textFieldPhoneNumber.text],@"consigneeName":self.textFieldName.text ,@"consigneeCountyCode":@"",@"address":self.textFieldAddressedDetail.text,@"isPaidAdvance":strDianFU,@"waybillPrice":[NSString stringWithFormat:@"%.0f",[self.textFieldJinE.text floatValue]*100],@"content":self.textViewBeiZhu.text,@"cmdCode":g_sendWaybillCmd,@"sendWaybillClerkLatitude":[AppManager valueForKey:@"latitude"],@"sendWaybillClerkLongitude":[AppManager valueForKey:@"longitude"]};
            //            }else{
            //                params = @{@"consigneeTel":[NSString stringWithFormat:@"%@",self.textFieldPhoneNumber.text],@"consigneeName":self.textFieldName.text ,@"consigneeCountyCode":@"",@"address":self.textFieldAddressedDetail.text,@"isPaidAdvance":strDianFU,@"waybillPrice":[NSString stringWithFormat:@"%.0f",[self.textFieldJinE.text floatValue]*100],@"content":self.textViewBeiZhu.text,@"cmdCode":g_shopLogCmd};
            //            }
        }
        FLDDLogDebug(@"params:%@", params);
        //        [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeBlack];
        [SelfUser hudShowWithViewcontroller:self];
        
        [[API shareAPI] REQUES:@"POST" WITHURL:@"sendWaybillJsonPhone.htm" params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SelfUser currentSelfUser].isNeedReturnLanShou = YES;
            //            [SVProgressHUD showSuccessWithStatus:@"发单成功"];
            [SelfUser hudHideWithViewcontroller:self];
            [MBProgressHUD hudShowWithStatus:self :@"发单成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(id responseObject, NSError *error) {
            [SelfUser hudHideWithViewcontroller:self];
            //            [SVProgressHUD showErrorWithStatus:[SelfUser currentSelfUser].ErrorMessage];
            NSInteger mark = [[[responseObject objectForKey:@"body"] objectForKey:@"sendWaybillFailureMark"] integerValue];
            
            if (mark == 1) {
                
                UIAlertView *alertView = nil;
                if ([[SelfUser currentSelfUser].Clerktype isEqualToString:@"1"]) {
                    alertView = [[UIAlertView alloc] initWithTitle:@"发单失败" message:@"账户余额不足，无法发单，请及时充值" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"充值", nil];
                }
                else {
                    alertView = [[UIAlertView alloc] initWithTitle:@"发单失败" message:@"账户余额不足，无法发单，请提醒店长充值" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"", nil];
                    
                }
                alertView.tag = 1888;
                [alertView show];
            }
            else {
                [MBProgressHUD hudShowWithStatus:self :[error localizedDescription]];
                
            }
        }];
//        [[API shareAPI]POST:@"sendWaybillJsonPhone.htm" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            
//        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            //            [SVProgressHUD dismiss ];
//            [SelfUser hudHideWithViewcontroller:self];
//            [SelfUser currentSelfUser].isNeedReturnLanShou = YES;
//            //            [SVProgressHUD showSuccessWithStatus:@"发单成功"];
//            [MBProgressHUD hudShowWithStatus:self :@"发单成功"];
//            
//            [self.navigationController popViewControllerAnimated:YES];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //            [SVProgressHUD dismiss ];
//            [SelfUser hudHideWithViewcontroller:self];
//            //            [SVProgressHUD showErrorWithStatus:[SelfUser currentSelfUser].ErrorMessage];
//            [MBProgressHUD hudShowWithStatus:self :[SelfUser currentSelfUser].ErrorMessage];
//            
//        }];
        
        
    }
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}
-(void)inputTEL{
    
    //    if (self.isMobilePhone) {
    //        self.isNowBilePhone = YES;
    //        self.labelFuHao.hidden = YES;
    //        self.textFenJi.hidden = YES;
    //        self.textFieldPhoneNumber.text = @"";
    //           self.sysPhoneNumber.text= @"手机号码";
    //        [self.buttonInputTEL setTitle:@"填写座机" forState:UIControlStateNormal];
    //        self.textFieldPhoneNumber.placeholder = @"请输入手机号码";
    //    }else{
    //        self.textFieldPhoneNumber.text = @"";
    //
    //        self.isNowBilePhone = NO;
    //        self.labelFuHao.hidden = NO;
    //        self.textFenJi.hidden = NO;
    //        self.sysPhoneNumber.text = [NSString stringWithFormat:@"座机%@-",[SelfUser currentSelfUser].strQuHaoTEL];
    //        [self.buttonInputTEL setTitle:@"填写手机" forState:UIControlStateNormal];
    //        self.textFieldPhoneNumber.placeholder = @"请输入座机";
    //    }
    //
    //        self.isMobilePhone = !self.isMobilePhone;
    
    if (!self.isMobilePhone) {
        self.isNowBilePhone = YES;
        self.labelFuHao.hidden = YES;
        self.textFenJi.hidden = YES;
        self.textFieldPhoneNumber.text = @"";
        self.sysPhoneNumber.text= @"手机号码";
        [self.buttonInputTEL setTitle:@"切换至座机" forState:UIControlStateNormal];
        self.textFieldPhoneNumber.placeholder = @"请输入手机号码";
        //        self.textFieldName.frame = CGRectMake(110, 0, 300, 44);
        self.textFiledQuHao.hidden = YES;
    }else{
        self.textFieldPhoneNumber.text = @"";
        
        self.isNowBilePhone = NO;
        self.labelFuHao.hidden = NO;
        self.textFenJi.hidden = NO;
        self.sysPhoneNumber.text = @"座机";
        [self.buttonInputTEL setTitle:@"切换至手机" forState:UIControlStateNormal];
        self.textFieldPhoneNumber.placeholder = @"请输入座机号码";
        //        self.textFieldName.frame = CGRectMake(60, 0, 300, 44);
        self.textFiledQuHao.hidden = NO;
    }
    
    self.isMobilePhone = !self.isMobilePhone;
    
    
}
-(BOOL)checkName:(NSString *)_text
{
    NSString *Regex = @"^[A-Za-z\u4e00-\u9fa5]*$";
    NSPredicate *Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [Test evaluateWithObject:_text];
}
-(void)locationNoti{
    
    
    if (self.isJISuButton) {
        self.isJISuButton = NO;
    }
    else{
        return;
    }
     [SelfUser hudHideWithViewcontroller:self];
    //    [self.textViewBeiZhu resignFirstResponder];
    //    NSDictionary* dict = @{@"consigneeTel":self.textFieldPhoneNumber.text,@"consigneeName":@"收货人姓名" ,@"consigneeCountyCode":@"所在区编码",@"address":@"详细地址",@"isPaidAdvance":@"2",@"waybillPrice":self.textFieldJinE.text,@"content":self.textViewBeiZhu.text};
    
    //    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认消息" message:[NSString stringWithFormat:@"收货人地址: %@-%@",self.textFieldAddressedDetail.text,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
    //    [alert show];
    //
    
    //    FLDDLogDebug(@"%lu",(unsigned long)self.textFieldAddressedDetail.text);
    //    FLDDLogDebug(@"%lu",(unsigned long)self.textFieldAddressedDetail.text.length);
    if (self.isNowBilePhone? [CommonUtils checkMobile:self.textFieldPhoneNumber.text]:self.textFieldPhoneNumber.text.length>=7 ) {
        //        if ([self.strDistriCode toString].length >0) {
        if (self.textFieldAddressedDetail.text.length>0 ) {
            if (self.textFieldJinE.text.length>0 && ![ [NSString stringWithFormat:@"%.0f",[self.textFieldJinE.text floatValue]*100] intValue] == 0) {
                if ( !self.isNowBilePhone &&self.textFiledQuHao.text.length<3) {
                    //                     [SVProgressHUD showErrorWithStatus:@"请输入正确区号"];
                    [MBProgressHUD hudShowWithStatus:self :@"请输入正确区号"];
                    return;
                }
                //                if (self.textFieldName.text.length==0) {
                //
                //                    //                    NSString* str= [self.textFieldAddressedDetail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                //
                //                    if (self.isNowBilePhone) {
                //
                //                        //                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@%@，电话－%@",self.strQu,str,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                //                        //                            [alert show];
                //                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@,电话－%@",self.textFieldAddressedDetail.text,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                //                        [alert show];
                //                    }else{
                //                        //                            if (self.textFenJi.text.length >0) {
                //                        //                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@%@，座机%@-%@-%@",self.strQu,str,[SelfUser currentSelfUser].strQuHaoTEL,self.textFieldPhoneNumber.text,self.textFenJi.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                //                        //                                [alert show];
                //                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@，座机%@-%@",self.textFieldAddressedDetail.text,self.textFiledQuHao.text,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                //                        [alert show];
                //
                //                        //                            }else{
                //                        //                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@，座机%@-%@",self.textFieldAddressedDetail.text,textFiledQuHao.text,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                //                        //                                [alert show];
                //                        //                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@%@，座机%@-%@",self.strQu,str,[SelfUser currentSelfUser].strQuHaoTEL,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                //                        //                                [alert show];
                //
                //                        //                            }
                //
                //
                //
                //
                //                    }
                //                }else{
                if ((self.textFieldName.text.length >=2&&self.textFieldName.text.length<=10) || self.textFieldName.text.length == 0) {
                    if ((![CommonUtils checkShuZiWithBiaoDianWithString:self.textFieldName.text])||self.textFieldName.text.length == 0 ) {
                        
                        NSString* str= [self.textFieldAddressedDetail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                        if (self.isNowBilePhone) {
                            
                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@，电话－%@",str,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                            [alert show];
                        }else{
                            
                            //                                    if (self.textFenJi.text.length >0) {
                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@，座机%@-%@",str,self.textFiledQuHao.text,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                            [alert show];
                            //                                    }else{
                            //                                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"确认信息" message:[NSString stringWithFormat:@"收货人地址:%@，座机%@-%@",str,[SelfUser currentSelfUser].strQuHaoTEL,self.textFieldPhoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发单", nil];
                            //                                        [alert show];
                            //
                            //                                    }
                            
                            
                        }
                    }else {
                        //                            [SVProgressHUD showErrorWithStatus:@"姓名只能为汉字或字母"];
                        [MBProgressHUD hudShowWithStatus:self :@"姓名只能为汉字或字母"];
                        
                    }
                }else{
                    //                        [SVProgressHUD showErrorWithStatus:@"姓名长度2-10位"];
                    [MBProgressHUD hudShowWithStatus:self :@"姓名长度2-10位"];
                }
                //                }
                
                
                
                //                    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"返回修改" destructiveButtonTitle:nil otherButtonTitles:self.textFieldPhoneNumber.text,self.textFieldAddressedDetail.text,@"确认发货", nil];
                //                    [actionSheet showInView:self.view];
                
                
            }else{
                FLDDLogDebug(@"%@",self.textFieldJinE.text);
                //                [SVProgressHUD showErrorWithStatus:@"请输入正确的金额"];
                [MBProgressHUD hudShowWithStatus:self :@"请输入正确的金额"];
            }
        }else{
            FLDDLogDebug(@"%@",self.strAddres);
            //            [SVProgressHUD showErrorWithStatus:@"请输入详细地址"];
            [MBProgressHUD hudShowWithStatus:self :@"请输入详细地址"];
        }
        //        }
        //    else{
        //            FLDDLogDebug(@"~~%@",self.strDistriCode);
        //            [SVProgressHUD showErrorWithStatus:@"请选择地区"];
        //        }
    }else{
        //        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",self.isNowBilePhone?@"请输入正确的手机号":@"请输入正确的座机号"]];
        [MBProgressHUD hudShowWithStatus:self :(self.isNowBilePhone?@"请输入正确的手机号":@"请输入正确的座机号")];
    }

}

@end
