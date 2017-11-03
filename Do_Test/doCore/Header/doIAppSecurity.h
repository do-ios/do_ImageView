//
//  doIAppSecurity.h
//  DoCore
//
//  Created by wl on 15/8/28.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIAppSecurity <NSObject>
@property (nonatomic,strong) NSString* appVersion;
- (NSString *)getDataKey;
- (NSString *)getCodeKey;
@end
