//
//  doIPageView.h
//  libDolib
//
//  Created by 程序员 on 14/11/11.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIPage;

@protocol doIPageView

#pragma mark -
@property (nonatomic, readonly,strong) id<doIPage> PageModel;
@property (nonatomic, strong) NSString *CustomScriptType;
@property (nonatomic, strong) NSString *statusBarFgColor;
@property (nonatomic, strong) NSString *statusBarState;
@property (nonatomic, strong) NSString *pageId;
@property (nonatomic, strong) NSString *openPageAnimation;
@property (nonatomic, strong) NSArray *supportCloseParms;

#pragma mark -
@required
- (void) DisposeView;

@end
