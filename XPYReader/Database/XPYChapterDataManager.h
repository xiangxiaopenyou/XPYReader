//
//  XPYChapterDataManager.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//  章节数据管理

#import <Foundation/Foundation.h>

@class XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYChapterDataManager : NSObject

/// 插入或替换章节信息
/// @param chapterModel 章节模型
+ (void)insertOrReplaceChapterWithModel:(XPYChapterModel *)chapterModel;

/// 插入多个章节信息
/// @param chapters 章节数组
+ (void)insertChaptersWithModels:(NSArray *)chapters;

/// 获取章节信息
/// @param bookId 书籍ID
/// @param chapterId 章节ID
+ (XPYChapterModel *)chapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

/// 判断是否存在某章节信息
/// @param bookId 书籍ID
/// @param chapterId 章节ID
+ (BOOL)isExsitWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

/// 删除某本书籍的所有章节信息
/// @param bookId 书籍ID
+ (void)deleteAllChaptersWithBookId:(NSString *)bookId;

@end

NS_ASSUME_NONNULL_END
