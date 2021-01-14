//
//  XPYReadView.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYReadView, XPYChapterPageModel, XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadView : UIView

/// 设置内容
/// @param pageModel 页面数据
/// @param chapterModel 章节数据
- (void)setupPageModel:(XPYChapterPageModel *)pageModel chapter:(XPYChapterModel *)chapterModel;

@end

NS_ASSUME_NONNULL_END
