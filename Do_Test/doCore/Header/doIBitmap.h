//
//  doIBitmap.h
//  DoCore
//
//  Created by yz on 16/5/17.
//  Copyright © 2016年 DongXian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol doIBitmap <NSObject>

@optional
- (void) setData:(UIImage *)_bitmap;
- (UIImage *)getData;

@end