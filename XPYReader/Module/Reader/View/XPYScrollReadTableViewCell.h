//
//  XPYScrollReadTableViewCell.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//  上下翻页模式每页视图

#import <UIKit/UIKit.h>
@class XPYChapterPageModel, XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYScrollReadTableViewCell : UITableViewCell

- (void)setupChapterPageModel:(XPYChapterPageModel *)pageModel chapterModel:(XPYChapterModel *)chapterModel;

@end

NS_ASSUME_NONNULL_END
