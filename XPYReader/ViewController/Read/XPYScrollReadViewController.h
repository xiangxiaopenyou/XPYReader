//
//  XPYScrollReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//  上下滚动翻页模式控制器

#import "XPYBaseViewController.h"
@class XPYBookModel, XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYScrollReadViewControllerDelegate <NSObject>

/// 开始拖动列表
- (void)scrollReadViewControllerWillBeginDragging;

@end

@interface XPYScrollReadViewController : XPYBaseViewController

- (instancetype)initWithBook:(XPYBookModel *)book;

@property (nonatomic, weak) id <XPYScrollReadViewControllerDelegate> scrollReadDelegate;

@end

NS_ASSUME_NONNULL_END
