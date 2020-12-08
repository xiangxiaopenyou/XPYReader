//
//  XPYOpenBookAnimation.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/28.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYOpenBookAnimation.h"

@interface XPYOpenBookAnimation ()

@property (nonatomic, strong) UIView *coverView;

@end

@implementation XPYOpenBookAnimation

+ (id<UIViewControllerAnimatedTransitioning>)animationWithCoverView:(UIView *)coverView {
    XPYOpenBookAnimation *animation = [[XPYOpenBookAnimation alloc] init];
    animation.coverView = coverView;
    return animation;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取目标视图
//    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *tempFromView = nil;
    UIView *tempToView = toController.view;
//    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {    //iOS8
//        tempToView = [transitionContext viewForKey:UITransitionContextToViewKey];
//        tempFromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//    } else {
//    tempToView = toController.view;
//    tempFromView = fromController.view;
//    }
    // 截图(afterScreenUpdates:是否所有效果应用在视图以后再截图)
    UIView *fromView = [self.coverView snapshotViewAfterScreenUpdates:NO];
    UIView *toView = [tempToView snapshotViewAfterScreenUpdates:YES];
    
    //fromView和toView加入到containerView中
    [transitionContext.containerView addSubview:toView];
    [transitionContext.containerView addSubview:fromView];
    
    // 保存frame
    CGRect fromFrame = self.coverView.frame;
    CGRect toFrame = toView.frame;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // 修改anchorPoint为(0, 0.5)(Y轴中间位置)
    fromView.layer.anchorPoint = CGPointMake(0, 0.5);
    
    // 修改了anchorPoint之后需要重新设置frame
    fromView.frame = fromFrame;
    // toView初始位置与fromView一样
    toView.frame = fromFrame;
    // 动画
    [UIView animateWithDuration:duration animations:^{
        // 沿Y轴逆时针旋转90度
        fromView.layer.transform = CATransform3DMakeRotation(- M_PI_2, 0, 1, 0);
        // frame变化
        fromView.frame = toFrame;
        toView.frame = toFrame;
    } completion:^(BOOL finished) {
        // 动画结束移除截图
        [fromView removeFromSuperview];
        [toView removeFromSuperview];
        
        // bookCoverView设为nil
        self.coverView = nil;
        
        // containerView添加目标视图
        [transitionContext.containerView addSubview:tempToView];
        // 还原子视图
        [transitionContext.containerView.layer setSublayerTransform:CATransform3DIdentity];
        // 结束转场（这里使用!transitionContext.transitionWasCancelled，避免手势取消时造成卡顿现象）
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}

/// 动画时间
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.8;
}

@end
