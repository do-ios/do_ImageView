//
//  doIBorder.h
//  DoCore
//
//  Created by wl on 16/3/25.
//  Copyright © 2016年 DongXian. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol doIBorder <NSObject>
@optional
- (int)isResetBorder;
- (BOOL)isSupportDiffBorder;
- (void)generateBorderWithPath:(UIBezierPath *)path :(CAShapeLayer *)shape;
- (void)clearBorder;
@end