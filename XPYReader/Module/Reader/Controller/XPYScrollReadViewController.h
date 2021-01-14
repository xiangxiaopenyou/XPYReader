//
//  XPYScrollReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//  上下滚动翻页模式和自动阅读滚屏模式控制器(因为使用的都是滚动列表)

#import "XPYBaseReadViewController.h"
@class XPYBookModel, XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYScrollReadViewControllerDelegate <NSObject>

/// 开始拖动列表
- (void)scrollReadViewControllerWillBeginDragging;

@optional
/// 全书读完
- (void)scrollReadViewControllerDidReadEnding;

@end

@interface XPYScrollReadViewController : XPYBaseReadViewController

@property (nonatomic, weak) id <XPYScrollReadViewControllerDelegate> scrollReadDelegate;

- (instancetype)initWithBook:(XPYBookModel *)book;

/// 更新自动阅读状态
/// @param status YES开始 NO停止
- (void)updateAutoReadStatus:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
