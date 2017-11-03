//
//  doIApp.h
//  libDolib
//
//  Created by sqs on 14-11-11.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "doMultitonModule.h"
@protocol doIDataFS;
@protocol doISourceFS;
@protocol doIScriptEngine;

@protocol doIApp <NSObject>
#pragma mark -
@property (nonatomic, readonly, strong)NSString * AppID;
@property (nonatomic, readonly, strong)id<doIDataFS> DataFS;
@property (nonatomic, readonly, strong)id<doISourceFS> SourceFS;
@property (nonatomic,readonly,strong) id<doIScriptEngine> ScriptEngine;

#pragma mark -
@required
-(doMultitonModule*) CreateMultitonModule:(NSString*) _typeID :(NSString*) _id;
-(doMultitonModule*) GetMultitonModuleByAddress:(NSString*) _key;
-(BOOL) DeleteMultitonModule:(NSString*) _address;
-(void) Dispose;
@end
