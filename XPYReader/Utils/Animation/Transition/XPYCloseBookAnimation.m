//
//  XPYCloseBookAnimation.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/10/9.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYCloseBookAnimation.h"

@interface XPYCloseBookAnimation ()

@property (nonatomic, strong) UIView *coverView;

@end

@implementation XPYCloseBookAnimation

+ (id<UIViewControllerAnimatedTransitioning>)animationWithCoverView:(UIView *)coverView {
    XPYCloseBookAnimation *animation = [[XPYCloseBookAnimation alloc] init];
    animation.coverView = coverView;
    return animation;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *tempFromView = nil;
    UIView *tempToView = nil;
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {    //iOS8
        tempFromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        tempToView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        tempFromView = fromController.view;
        tempToView = toController.view;
    }
    UIView *toView = [self.coverView snapshotViewAfterScreenUpdates:YES];
    UIView *fromView = [tempFromView snapshotViewAfterScreenUpdates:NO];
    [transitionContext.containerView addSubview:fromView];
    [transitionContext.containerView addSubview:toView];
    
    // 保存frame
    CGRect fromFrame = fromView.frame;
    CGRect toFrame = self.coverView.frame;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // 修改anchorPoint为(0, 0.5)(Y轴中间位置)
    toView.layer.anchorPoint = CGPointMake(0, 0.5);
    
    // 修改了anchorPoint之后需要重新设置frame
    fromView.frame = fromFrame;
    // toView初始位置与fromView一样
    toView.frame = fromFrame;
    // 设置toViewY轴初始位置旋转角度
    toView.layer.transform = CATransform3DMakeRotation(- M_PI_2, 0, 1, 0);
    
    // 添加toView并隐藏fromView
    [transitionContext.containerView insertSubview:tempToView atIndex:0];
    tempFromView.hidden = YES;
    
    [UIView animateWithDuration:duration animations:^{
        toView.layer.transform = CATransform3DIdentity;
        fromView.frame = toFrame;
        toView.frame = toFrame;
    } completion:^(BOOL finished) {
        // 动画结束移除截图
        [fromView removeFromSuperview];
        [toView removeFromSuperview];
        
        // bookCoverView设为nil
        self.coverView = nil;
        
        // 还原子视图
        [transitionContext.containerView.layer setSublayerTransform:CATransform3DIdentity];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            tempFromView.hidden = NO;
            [tempToView removeFromSuperview];
        }
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.8;
}

@end
