//
//  XPYPageReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//  仿真、左右平移、无效果翻页模式控制器

#import <UIKit/UIKit.h>

@class XPYBookModel, XPYPageReadViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYPageReadViewControllerDelegate <NSObject>

@optional
- (void)pageReadViewControllerWillTransition;

@end

@interface XPYPageReadViewController : UIPageViewController

/// 初始化方法
/// @param book 书籍Model
- (instancetype)initWithBook:(XPYBookModel *)book;

@property (nonatomic, weak) id <XPYPageReadViewControllerDelegate> pageReadDelegate;

@end

NS_ASSUME_NONNULL_END
