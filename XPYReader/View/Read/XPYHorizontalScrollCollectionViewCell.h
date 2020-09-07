//
//  XPYHorizontalScrollCollectionViewCell.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYChapterModel, XPYChapterPageModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYHorizontalScrollCollectionViewCell : UICollectionViewCell

- (void)setupChapter:(XPYChapterModel *)chapter pageModel:(XPYChapterPageModel *)pageModel;

@end

NS_ASSUME_NONNULL_END
