//
//  XPYChapterHelper.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/12.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYChapterHelper.h"
#import "XPYChapterDataManager.h"
#import "XPYReadRecordManager.h"
#import "XPYChapterModel.h"
#import "XPYNetworkService+Chapter.h"

@implementation XPYChapterHelper

+ (void)chapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId success:(void (^)(XPYChapterModel * _Nonnull))success failure:(void (^)(NSString * _Nonnull))failure {
    // chapterId为空时获取书籍第一章
    if (!chapterId) {
        // 该书籍是否保存了章节信息
        BOOL isExsitChapters = [XPYChapterDataManager isExsitChaptersWithBookId:bookId];
        if (isExsitChapters) {
            // 存在章节信息则获取第一章
            XPYChapterModel *firstChapter = [XPYChapterDataManager chapterWithBookId:bookId chapterId:nil];
            if (XPYIsEmptyObject(firstChapter.content)) {
                // 章节内容为空时需要请求章节内容
                [self reqeustChapterContentWithChapter:firstChapter success:^(id result) {
                    !success ?: success((XPYChapterModel *)result);
                } failure:^(NSString *tip) {
                    !failure ?: failure(tip);
                }];
            } else {
                // 存在章节内容时直接返回
                !success ?: success(firstChapter);
            }
        } else {
            // 不存在章节信息则请求书籍章节信息
            [self requestBaseChapterInformationsWithBookId:bookId success:^(id result) {
                XPYChapterModel *firstChapter = [[(NSArray *)result firstObject] copy];
                // 请求章节内容
                [self reqeustChapterContentWithChapter:firstChapter success:^(id result) {
                    !success ?: success((XPYChapterModel *)result);
                } failure:^(NSString *tip) {
                    !failure ?: failure(tip);
                }];
            } failure:^(NSString *tip) {
                !failure ?: failure(tip);
            }];
        }
    } else {
        // 该书籍是否保存了特定章节信息
        BOOL isExsitOneChapter = [XPYChapterDataManager isExsitWithBookId:bookId chapterId:chapterId];
        if (isExsitOneChapter) {
            XPYChapterModel *oneChapter = [XPYChapterDataManager chapterWithBookId:bookId chapterId:chapterId];
            if (XPYIsEmptyObject(oneChapter.content)) {
                // 章节内容为空时需要请求章节内容
                [self reqeustChapterContentWithChapter:oneChapter success:^(id result) {
                    !success ?: success((XPYChapterModel *)result);
                } failure:^(NSString *tip) {
                    !failure ?: failure(tip);
                }];
            } else {
                // 存在章节内容时直接返回
                !success ?: success(oneChapter);
            }
        } else {
            // 不存在章节信息则请求书籍章节信息
            [self requestBaseChapterInformationsWithBookId:bookId success:^(id result) {
                // 查找需要的章节信息
                for (XPYChapterModel *model in (NSArray *)result) {
                    if ([model.chapterId isEqualToString:chapterId]) {
                        XPYChapterModel *oneChapter = [model copy];
                        // 请求章节内容
                        [self reqeustChapterContentWithChapter:oneChapter success:^(id result) {
                            !success ?: success((XPYChapterModel *)result);
                        } failure:^(NSString *tip) {
                            !failure ?: failure(tip);
                        }];
                        break;
                    }
                }
            } failure:^(NSString *tip) {
                !failure ?: failure(tip);
            }];
        }
    }
}

+ (void)chaptersWithBookId:(NSString *)bookId success:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSString * _Nonnull))failure {
    NSArray *chapters = [XPYChapterDataManager chaptersWithBookId:bookId];
    if (chapters.count == 0) {
        [self requestBaseChapterInformationsWithBookId:bookId success:^(id result) {
            !success ?: success((NSArray *)result);
        } failure:^(NSString *tip) {
            !failure ?: failure(tip);
        }];
    } else {
        !success ?: success(chapters);
    }
}

+ (XPYChapterModel *)lastChapterOfCurrentChapter:(XPYChapterModel *)currentChapter {
    return [XPYChapterDataManager chapterWithBookId:currentChapter.bookId chapterIndex:currentChapter.chapterIndex - 1];
}

+ (XPYChapterModel *)nextChapterOfCurrentChapter:(XPYChapterModel *)currentChapter {
    return [XPYChapterDataManager chapterWithBookId:currentChapter.bookId chapterIndex:currentChapter.chapterIndex + 1];
}

+ (void)preloadNextChapterWithCurrentChapter:(XPYChapterModel *)currentChapter complete:(void (^)(XPYChapterModel * _Nullable))complete {
    if (!currentChapter) {
        return;
    }
    __block XPYChapterModel *nextChapter = [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter];
    if (!nextChapter) {
        return;
    }
    if (XPYIsEmptyObject(nextChapter.content)) {
        [self reqeustChapterContentWithChapter:nextChapter success:^(id result) {
            !complete ?: complete((XPYChapterModel *)result);
        } failure:^(NSString *tip) {
        }];
    } else {
        // 已经存在章节内容直接返回
        !complete ?: complete(nextChapter);
    }
}

+ (void)preloadLastChapterWithCurrentChapter:(XPYChapterModel *)currentChapter complete:(void (^)(XPYChapterModel * _Nullable))complete {
    __block XPYChapterModel *lastChapter = [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
    if (!lastChapter) {
        return;
    }
    if (XPYIsEmptyObject(lastChapter.content)) {
        [self reqeustChapterContentWithChapter:lastChapter success:^(id result) {
            !complete ?: complete((XPYChapterModel *)result);
        } failure:^(NSString *tip) {
        }];
    } else {
        // 已经存在章节内容直接返回
        !complete ?: complete(lastChapter);
    }
}

+ (void)downloadChaptersContentWithBookId:(NSString *)bookId chapterIds:(NSArray *)chapterIds progress:(void (^)(NSInteger))progress complete:(nullable void (^)(BOOL, NSString * _Nonnull, NSArray * _Nullable))complete {
    if (XPYIsEmptyObject(bookId)) {
        !complete ?: complete(NO, @"未知书籍", nil);
    }
    if (chapterIds.count == 0) {
        !complete ?: complete(NO, @"未知章节", nil);
    }
    // 统计下载章节数量
    __block NSInteger downloadCount = 0;
    // 统计下载失败章节ID
    __block NSMutableArray *failureArray = [[NSMutableArray alloc] init];
    for (NSString *chapterId in chapterIds) {
        if (XPYIsEmptyObject(chapterId)) {
            downloadCount += 1;
            if (downloadCount == chapterIds.count) {
                !complete ?: complete(YES, @"下载完成", failureArray);
            } else {
                !progress ?: progress(downloadCount);
            }
            continue;
        }
        [self chapterWithBookId:bookId chapterId:chapterId success:^(XPYChapterModel * _Nonnull chapter) {
            downloadCount += 1;
            if (downloadCount == chapterIds.count) {
                !complete ?: complete(YES, @"下载完成", failureArray);
            } else {
                !progress ?: progress(downloadCount);
            }
        } failure:^(NSString * _Nonnull tip) {
            downloadCount += 1;
            // 保存失败章节ID
            [failureArray addObject:chapterId];
            if (downloadCount == chapterIds.count) {
                !complete ?: complete(YES, @"下载完成", failureArray);
            } else {
                !progress ?: progress(downloadCount);
            }
        }];
    }
}

#pragma mark - Private class methods
// 请求书籍章节基本信息
+ (void)requestBaseChapterInformationsWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(void (^)(NSString * tip))failure {
    [[XPYNetworkService sharedService] bookChaptersWithBookId:bookId success:^(id result) {
        NSArray *chapters = [(NSArray *)result copy];
        if (chapters.count > 0) {
            // 保存章节基本信息
            [XPYChapterDataManager insertChaptersWithModels:chapters];
            !success ?: success(chapters);
        } else {
            !failure ?: failure(@"无相关章节");
        }
    } failure:^(NSError *error) {
        !failure ?: failure(@"请求章节信息失败");
    }];
}

// 请求书籍章节内容
+ (void)reqeustChapterContentWithChapter:(XPYChapterModel *)chapter success:(XPYSuccessHandler)success failure:(void (^)(NSString * tip))failure {
    [[XPYNetworkService sharedService] chapterContentWithBookId:chapter.bookId chapterId:chapter.chapterId success:^(id result) {
        NSString *content = (NSString *)result;
        if (XPYIsEmptyObject(content)) {
            !failure ?: failure(@"章节内容为空");
        } else {
            chapter.content = content;
            // 保存章节内容
            [XPYChapterDataManager insertChaptersWithModels:@[chapter]];
            !success ?: success(chapter);
        }
    } failure:^(NSError *error) {
        !failure ?: failure(@"请求章节内容失败");
    }];
}


@end
