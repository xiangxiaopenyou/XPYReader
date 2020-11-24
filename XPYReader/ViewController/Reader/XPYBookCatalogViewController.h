//
//  XPYBookCatalogViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/11/24.
//  Copyright © 2020 xiang. All rights reserved.
//  书籍目录控制器

#import "XPYBaseViewController.h"

@class XPYBookModel, XPYChapterModel, XPYBookCatalogViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYBookCatalogDelegate <NSObject>

- (void)bookCatalog:(XPYBookCatalogViewController *)catalogController didSelectChapter:(XPYChapterModel *)chapter;

@end

@interface XPYBookCatalogViewController : XPYBaseViewController

@property (nonatomic, weak) id<XPYBookCatalogDelegate> delegate;

@property (nonatomic, strong) XPYBookModel *book;

@end

NS_ASSUME_NONNULL_END
