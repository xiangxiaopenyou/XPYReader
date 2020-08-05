//
//  XPYReadPageViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadPageViewController : UIViewController

@property (nonatomic, strong) XPYBookModel *book;

@property (nonatomic, copy) NSArray <XPYChapterModel *> *chapters;  // 章节信息

@end

NS_ASSUME_NONNULL_END
