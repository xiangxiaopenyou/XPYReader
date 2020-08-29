//
//  XPYTimerProxy.m
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2020/4/29.
//  Copyright © 2020 xpy. All rights reserved.
//

#import "XPYTimerProxy.h"

@interface XPYTimerProxy ()

/// 弱引用对象，解决循环引用
@property (nonatomic, weak) id target;

@end

@implementation XPYTimerProxy

+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    self.target = target;
    return self;
}

#pragma mark - 消息转发，转发给target对象
// 转发目标选择器
//- (id)forwardingTargetForSelector:(SEL)selector {
//    return self.target;
//}
- (void)forwardInvocation:(NSInvocation *)invocation {
    if (self.target && [self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [self.target methodSignatureForSelector:sel];
    return signature;
}

@end
