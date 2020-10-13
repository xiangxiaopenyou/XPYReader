//
//  UIViewController+Transition.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/29.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Transition)

/// 书籍封面视图
@property (nonatomic, strong, nullable) UIView *bookCoverView;

@end

NS_ASSUME_NONNULL_END
