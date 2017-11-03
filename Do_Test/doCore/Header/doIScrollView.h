//
//  doIScrollView.h
//  DoCore
//
//  Created by wl on 15/8/27.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIScrollView <NSObject>
//若当前组件实现了doIScrollView协议，且子节点为doLinearLayout时，doLinearLayout的内容尺寸如果发生了变化，则该组件的contentSize要相应的发生变化
- (void) AdjustContentSize;
@end
