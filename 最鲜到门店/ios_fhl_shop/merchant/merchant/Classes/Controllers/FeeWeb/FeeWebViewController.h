//
//  FeeWebViewController.h
//  FHL
//
//  Created by panume on 14-10-20.
//  Copyright (c) 2014年 JUEWEI. All rights reserved.
//

#import "BaseViewController.h"

//typedef NS_ENUM(NSUInteger, WebViewType) {
//    WebViewTypeRegister,
//    WebViewTypePolicy
//};

@interface FeeWebViewController : BaseViewController

//@property (nonatomic, assign) WebViewType type;
@property (strong, nonatomic)UIButton* button;
@property (strong,nonatomic)UIActivityIndicatorView* activityIndicatorView;
@property (strong, nonatomic)NSString* waybillId;

@end
