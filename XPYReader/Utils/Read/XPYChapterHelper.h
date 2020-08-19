//
//  XPYChapterHelper.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/12.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYChapterHelper : NSObject

/// 获取章节
/// @param bookId 书籍ID
/// @param chapterId 章节ID（为空时获取第一章）
/// @param success 成功回调
/// @param failure 失败回调
+ (void)chapterWithBookId:(NSString *)bookId chapterId:(NSString * _Nullable)chapterId success:(void (^)(XPYChapterModel *chapter))success failure:(void (^)(NSString *tip))failure;

/// 获取指定书籍所有章节
/// @param bookId 书籍ID
/// @param success 成功回调
/// @param failure 失败回调
+ (void)chaptersWithBookId:(NSString *)bookId success:(void (^)(NSArray *chapters))success failure:(void (^)(NSString *tip))failure;

/// 获取当前章节的上一章节
/// @param currentChapter 当前章节
+ (XPYChapterModel *)lastChapterOfCurrentChapter:(XPYChapterModel *)currentChapter;

/// 获取当前章节的下一章节
/// @param currentChapter 当前章节
+ (XPYChapterModel *)nextChapterOfCurrentChapter:(XPYChapterModel *)currentChapter;

@end

NS_ASSUME_NONNULL_END
