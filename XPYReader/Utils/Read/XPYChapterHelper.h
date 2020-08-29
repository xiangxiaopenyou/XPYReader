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

/// 获取完整章节（包括章节内容）
/// @param bookId 书籍ID
/// @param chapterId 章节ID（为空时获取第一章）
/// @param success 成功回调
/// @param failure 失败回调
+ (void)chapterWithBookId:(NSString *)bookId chapterId:(NSString * _Nullable)chapterId success:(void (^)(XPYChapterModel *chapter))success failure:(void (^)(NSString *tip))failure;

/// 获取指定书籍所有章节（不一定包含章节内容，本地有章节内容则包含内容）
/// @param bookId 书籍ID
/// @param success 成功回调
/// @param failure 失败回调
+ (void)chaptersWithBookId:(NSString *)bookId success:(void (^)(NSArray *chapters))success failure:(void (^)(NSString *tip))failure;

/// 获取当前章节的上一章节（不一定包含章节内容，本地有章节内容则包含内容）
/// @param currentChapter 当前章节
+ (XPYChapterModel *)lastChapterOfCurrentChapter:(XPYChapterModel *)currentChapter;

/// 获取当前章节的下一章节（不一定包含章节内容，本地有章节内容则包含内容）
/// @param currentChapter 当前章节
+ (XPYChapterModel *)nextChapterOfCurrentChapter:(XPYChapterModel *)currentChapter;

/// 预加载当前章节的下一章节
/// @param currentChapter 当前章节
/// @param complete 完成回调(下一章节)
+ (void)preloadNextChapterWithCurrentChapter:(XPYChapterModel *)currentChapter complete:(nullable void (^)(XPYChapterModel * _Nullable nextChapter))complete;

/// 预加载当前章节的上一章节
/// @param currentChapter 当前章节
/// @param complete 完成回调(下一章节)
+ (void)preloadLastChapterWithCurrentChapter:(XPYChapterModel *)currentChapter complete:(nullable void (^)(XPYChapterModel * _Nullable lastChapter))complete;

/// 下载章节内容
/// @param bookId 书籍ID
/// @param chapterIds 章节ID数组
/// @param progress 进度回调(已经完成数量)
/// @param complete 完成回调(是否成功，成功或失败提示，下载失败章节ID数组)
+ (void)downloadChaptersContentWithBookId:(NSString *)bookId chapterIds:(NSArray *)chapterIds progress:(nullable void (^)(NSInteger finishedNumber))progress complete:(nullable void (^)(BOOL success, NSString *tip, NSArray * _Nullable failureChapterIds))complete;

@end

NS_ASSUME_NONNULL_END
