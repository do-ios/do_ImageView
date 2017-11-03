//
//  doEGOImageResource.h
//  DoCore
//
//  Created by yz on 15/6/8.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  图片资源
 *  把箭头图片存储为字符串
 */
@interface doEGOImageResource : NSObject
/**
 *  得到图片的base字符串
 *
 *  @return <#return value description#>
 */
+ (NSString *) getRefreshArrowImageStr;
@end
