//
//  XPYCloseBookAnimation.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/10/9.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYCloseBookAnimation : NSObject<UIViewControllerAnimatedTransitioning>

+ (id <UIViewControllerAnimatedTransitioning>)animationWithCoverView:(UIView *)coverView;

@end

NS_ASSUME_NONNULL_END
