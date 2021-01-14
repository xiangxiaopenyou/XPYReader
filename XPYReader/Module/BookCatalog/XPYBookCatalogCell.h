//
//  XPYBookCatalogCell.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/11/24.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYBookCatalogCell : UITableViewCell

- (void)setupChapter:(XPYChapterModel *)chapter;

@end

NS_ASSUME_NONNULL_END
