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
    BOOL yesOrNo = [[XPYDatabaseManager sharedInstance].database insertOrReplaceObject:chapterModel into:XPYChapterTable];
    NSLog(@"%@", @(yesOrNo));
}

+ (void)insertChaptersWithModels:(NSArray *)chapters {
    if (chapters.count == 0) {
        return;
    }
    [[XPYDatabaseManager sharedInstance].database runTransaction:^BOOL{
        [[XPYDatabaseManager sharedInstance].database insertOrReplaceObjects:chapters into:XPYChapterTable];
        return YES;
    }];
}

+ (XPYChapterModel *)chapterWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    if (!chapterId) {
        return [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYChapterModel class] fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId) orderBy:XPYChapterModel.chapterIndex.order(WCTOrderedAscending)];
    }
    return [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYChapterModel class] fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId) && XPYChapterModel.chapterId.is(chapterId)];
}

+ (XPYChapterModel *)chapterWithBookId:(NSString *)bookId chapterIndex:(NSInteger)chapterIndex {
    return [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYChapterModel class] fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId) && XPYChapterModel.chapterIndex.is(chapterIndex)];
}

+ (NSArray *)chaptersWithBookId:(NSString *)bookId {
    return [[XPYDatabaseManager sharedInstance].database getObjectsOfClass:[XPYChapterModel class] fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId) orderBy:XPYChapterModel.chapterIndex.order(WCTOrderedAscending)];
}

+ (BOOL)isExsitChaptersWithBookId:(NSString *)bookId {
    XPYChapterModel *model = [[XPYDatabaseManager sharedInstance].database getOneObjectOnResults:{XPYChapterModel.chapterId} fromTable:XPYChapterTable where:XPYChapterModel.bookId.is(bookId)];
    if (model) {
        return YES;
    }
    return NO;
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

+ (void)deleteAllChapters {
    [[XPYDatabaseManager sharedInstance].database deleteAllObjectsFromTable:XPYChapterTable];
}

@end
