//
//  XPYBookStackViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYBookStackViewController : XPYBaseViewController

/// 将要打开书籍视图
@property (nonatomic, strong, readonly) UIView *selectedBookView;

@end

NS_ASSUME_NONNULL_END
