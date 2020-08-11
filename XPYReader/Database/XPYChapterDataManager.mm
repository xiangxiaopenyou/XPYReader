//
//  XPYChapterDataManager.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYChapterDataManager.h"
#import "XPYChapterModel.h"
#import "XPYChapterModel+WCTTableCoding.h"
#import "XPYDatabaseManager.h"

@implementation XPYChapterDataManager

+ (void)insertOrReplaceChapterWithModel:(XPYChapterModel *)chapterModel {
    [[XPYDatabaseManager sharedInstance].database insertOrReplaceObject:chapterModel into:XPYChapterTable];
}

+ (void)insertChaptersWithModels:(NSArray *)chapters {
    if (chapters.count == 0) {
        return;
    }
    [[XPYDatabaseManager sharedInstance].database runTransaction:^BOOL{
        for (XPYChapterModel *chapterModel in chapters) {
            XPYChapterModel *tempModel = [self chapterWithBookId:chapterModel.bookId chapterId:chapterModel.chapterId];
            if (tempModel) {
                // 更新章节内容
                if (chapterModel.content.length > 0) {
                    [[XPYDatabaseManager sharedInstance].database updateRowsInTable:XPYChapterTable onProperty:XPYChapterModel.content withObject:chapterModel where:XPYChapterModel.bookId.is(tempModel.bookId) && XPYChapterModel.chapterId.is(tempModel.chapterId)];
                }
            } else {
                [self insertOrReplaceChapterWithModel:chapterModel];
            }
        }
        return YES;
    }];
}

+ (XPYChapterModel *)chapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    return [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYChapterModel class] fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId) && XPYChapterModel.chapterId.is(chapterId)];
}

+ (BOOL)isExsitWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    XPYChapterModel *chapterModel = [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYChapterModel class] fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId) && XPYChapterModel.chapterId.is(chapterId)];
    if (chapterModel) {
        return YES;
    }
    return NO;
}

+ (void)deleteAllChaptersWithBookId:(NSString *)bookId {
    [[XPYDatabaseManager sharedInstance].database deleteObjectsFromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId)];
}

@end
