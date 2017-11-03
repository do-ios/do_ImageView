//
//  doMultitonModule.h
//  DoCore
//
//  Created by 刘吟 on 14/12/3.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "doModuleBase.h"
@protocol doIApp;
//@class doModuleBase;

@interface doMultitonModule : doModuleBase
#pragma mark -
//当前所属应用
@property (nonatomic,weak) id<doIApp> CurrentApp;
- (void) LoadModelFromString: (NSString*) _moduleString;//装载配置
@end
