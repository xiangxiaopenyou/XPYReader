
//
//  XPYChapterModel.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYChapterModel.h"
#import <WCDB/WCDB.h>

@implementation XPYChapterModel

WCDB_IMPLEMENTATION(XPYChapterModel)
WCDB_SYNTHESIZE_COLUMN(XPYChapterModel, chapterId, "chapterId")
WCDB_SYNTHESIZE_COLUMN(XPYChapterModel, bookId, "bookId")
WCDB_SYNTHESIZE_COLUMN(XPYChapterModel, chapterIndex, "chapterIndex")
WCDB_SYNTHESIZE_COLUMN(XPYChapterModel, chapterName, "chapterName")
WCDB_SYNTHESIZE_COLUMN(XPYChapterModel, content,"content")
WCDB_SYNTHESIZE_COLUMN(XPYChapterModel, charNum, "charNum")


WCDB_INDEX(XPYChapterModel, "_bookId_chapterId_index", bookId)
WCDB_INDEX(XPYChapterModel, "_bookId_chapterId_index", chapterId)

WCDB_INDEX(XPYChapterModel, "_bookId_content_index", bookId)
WCDB_INDEX(XPYChapterModel, "_bookId_content_index", content)

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
        @"bookId": @"bid",
        @"chapterId": @"cid",
        @"chapterName": @"cn",
        @"chapterIndex" : @"id",
        @"charNum" : @"wc",
    };
}

@end
