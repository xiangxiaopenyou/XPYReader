//
//  XPYBookModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseModel.h"

#import "XPYChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYBookModel : XPYBaseModel

@property (nonatomic, copy) NSString *bookId;
@property (nonatomic, copy) NSString *bookName;
/// 书本封面图网络链接
@property (nonatomic, copy) NSString *bookCoverURL;
/// 书本介绍
@property (nonatomic, copy) NSString *bookIntroduction;
/// 最后打开书本时间
@property (nonatomic, assign) NSTimeInterval openTime;
/// 是否加入书架
@property (nonatomic, assign) BOOL isInStack;
///总章节数
@property (nonatomic, assign) NSInteger chapterCount;
/// 当前章节信息
@property (nonatomic, strong) XPYChapterModel *chapter;
/// 当前阅读章节页码
@property (nonatomic, assign) NSInteger page;

@end

NS_ASSUME_NONNULL_END
