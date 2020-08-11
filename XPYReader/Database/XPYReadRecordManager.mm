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
+ (XPYBookModel *)recordWithBookId:(NSString *)bookId {
    return [[XPYDatabaseManager sharedInstance].database getOneObjectOfClass:[XPYBookModel class] fromTable:XPYReadRecordTable where:XPYBookModel.bookId.is(bookId)];
}

@end
