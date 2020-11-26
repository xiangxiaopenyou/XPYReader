//
//  XPYReadRecordManager.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadRecordManager.h"
#import "XPYDatabaseManager.h"
#import "XPYBookModel.h"
#import "XPYBookModel+WCTTableCoding.h"

@implementation XPYReadRecordManager

+ (void)insertOrReplaceRecordWithModel:(XPYBookModel *)bookModel {
    bookModel.openTime = [NSDate date].timeIntervalSince1970;
    [[XPYDatabaseManager sharedInstance].database insertOrReplaceObject:bookModel into:XPYReadRecordTable];
}

+ (void)deleteRecordWithModel:(XPYBookModel *)bookModel {
    [[XPYDatabaseManager sharedInstance].database deleteObjectsFromTable:XPYReadRecordTable where:XPYBookModel.bookId.is(bookModel.bookId)];
}

+ (void)deleteAllReadRecords {
    [[XPYDatabaseManager sharedInstance].database deleteAllObjectsFromTable:XPYReadRecordTable];
}

+ (XPYBookModel *)recordWithBookId:(NSString *)bookId {
    return [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYBookModel class] fromTable:XPYReadRecordTable where:XPYBookModel.bookId.is(bookId)];
}

+ (void)updateOpenTimeWithModel:(XPYBookModel *)bookModel {
    bookModel.openTime = [NSDate date].timeIntervalSince1970;
    [[XPYDatabaseManager sharedInstance].database updateRowsInTable:XPYReadRecordTable onProperties:XPYBookModel.openTime withObject:bookModel where:XPYBookModel.bookId.is(bookModel.bookId)];
}

+ (void)updateInStackStatusWithModel:(XPYBookModel *)bookModel {
    [[XPYDatabaseManager sharedInstance].database updateRowsInTable:XPYReadRecordTable onProperties:XPYBookModel.isInStack withObject:bookModel where:XPYBookModel.bookId.is(bookModel.bookId)];
}

+ (void)updateChapterCountWithBookId:(NSString *)bookId count:(NSInteger)count {
    [[XPYDatabaseManager sharedInstance].database updateRowsInTable:XPYReadRecordTable onProperty:XPYBookModel.chapterCount withValue:@(count) where:XPYBookModel.bookId.is(bookId)];
}

+ (void)updateReadRecordWithModel:(XPYBookModel *)bookModel {
    bookModel.openTime = [NSDate date].timeIntervalSince1970;
    [[XPYDatabaseManager sharedInstance].database updateRowsInTable:XPYReadRecordTable onProperties:{XPYBookModel.chapter, XPYBookModel.page, XPYBookModel.openTime} withObject:bookModel where:XPYBookModel.bookId.is(bookModel.bookId)];
}

+ (NSArray *)allBooksInStack {
    return [[XPYDatabaseManager sharedInstance].database getObjectsOfClass:[XPYBookModel class] fromTable:XPYReadRecordTable where:XPYBookModel.isInStack.is(YES) orderBy:XPYBookModel.openTime.order(WCTOrderedDescending)];
}

+ (NSArray *)allReadBooks {
    return [[XPYDatabaseManager sharedInstance].database getAllObjectsOfClass:[XPYBookModel class] fromTable:XPYReadRecordTable];
}

@end
