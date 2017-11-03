//
//  doIPageViewFactory.h
//  DoCore
//
//  Created by 刘吟 on 14/11/16.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIPageViewFactory 

#pragma mark -
@required
- (void) OpenPage: (NSString*) _appID : (NSString*) _uiPath : (NSString*) _scriptType :  (NSString*) _animationType : (NSString*)_data : (NSString*)_statusBarState  : (NSString*)_keyboardMode :(NSString*) _callbackName :(NSString*)_statusBarFgColor :(NSString *)_pageId;
- (void) ClosePage:(NSString*) _animationType :(int)_layer :(NSString*) _data;
- (void) ClosePageToID:(NSString*) _animationType :(NSString *)_pageId :(NSString*) _data;
@end
