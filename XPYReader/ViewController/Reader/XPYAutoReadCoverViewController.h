//
//  XPYAutoReadCoverViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/28.
//  Copyright © 2020 xiang. All rights reserved.
//  自动阅读覆盖模式

#import "XPYBaseReadViewController.h"

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYAutoReadCoverViewControllerDelegate <NSObject>

@optional
/// 全书读完
- (void)autoReadCoverViewControllerDidEndEnding;

@end

@interface XPYAutoReadCoverViewController : XPYBaseReadViewController

@property (nonatomic, weak) id<XPYAutoReadCoverViewControllerDelegate> delegate;

- (instancetype)initWithBook:(XPYBookModel *)book;

/// 更新自动阅读状态
/// @param status YES开始 NO停止
- (void)updateAutoReadStatus:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
