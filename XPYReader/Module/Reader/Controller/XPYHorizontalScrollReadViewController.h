//
//  XPYHorizontalScrollReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/7.
//  Copyright © 2020 xiang. All rights reserved.
//  左右平移翻页模式控制器

#import "XPYBaseReadViewController.h"

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYHorizontalScrollReadViewControllerDelegate <NSObject>

/// 开始滑动
- (void)horizontalScrollReadViewControllerWillBeginScroll;

@end

@interface XPYHorizontalScrollReadViewController : XPYBaseReadViewController

@property (nonatomic, weak) id <XPYHorizontalScrollReadViewControllerDelegate> delegate;

- (instancetype)initWithBook:(XPYBookModel *)book;

@end

NS_ASSUME_NONNULL_END
