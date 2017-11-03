//
//  do_ImageView_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_ImageView_IView <NSObject>

@required
//属性方法
- (void)change_cacheType:(NSString *)newValue;
- (void)change_defaultImage:(NSString *)newValue;
- (void)change_enabled:(NSString *)newValue;
- (void)change_radius:(NSString *)newValue;
- (void)change_scale:(NSString *)newValue;
- (void)change_source:(NSString *)newValue;
- (void)change_animation:(NSString *)newValue;
//同步或异步方法
- (void)setBitmap:(NSArray *)parms;

@end