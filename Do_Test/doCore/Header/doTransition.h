//
//  doTransition.h
//  DoCore
//
//  Created by wl on 15/10/18.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    AnimationTypePresent,
    AnimationTypeDismiss
} AnimationType;

@interface doTransition : NSObject
- (id<UIViewControllerAnimatedTransitioning>)getTransitionAnimation:(NSString *)animationType :(double)duration :(AnimationType)transitionType :(BOOL)isInteraction; 
@end
