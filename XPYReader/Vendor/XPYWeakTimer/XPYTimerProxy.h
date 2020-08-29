//
//  XPYTimerProxy.h
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2020/4/29.
//  Copyright © 2020 xpy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYTimerProxy : NSProxy

/// 类方法初始化
/// @param target 传入对象
+ (instancetype)proxyWithTarget:(id)target;

/// 实例方法初始化
/// @param target 传入对象
- (instancetype)initWithTarget:(id)target;


@end

NS_ASSUME_NONNULL_END
