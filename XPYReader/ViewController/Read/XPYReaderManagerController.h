//
//  XPYReaderManagerController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//  阅读器总控制器

#import "XPYBaseReadViewController.h"

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYReaderManagerController : XPYBaseReadViewController

@property (nonatomic, strong) XPYBookModel *book;

@end

NS_ASSUME_NONNULL_END
