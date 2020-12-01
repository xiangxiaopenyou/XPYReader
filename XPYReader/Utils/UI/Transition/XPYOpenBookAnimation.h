//
//  XPYOpenBookAnimation.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/28.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYOpenBookAnimation : NSObject <UIViewControllerAnimatedTransitioning>

+ (id <UIViewControllerAnimatedTransitioning>)animationWithCoverView:(UIView *)coverView;

@end

NS_ASSUME_NONNULL_END
