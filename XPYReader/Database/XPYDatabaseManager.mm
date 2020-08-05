//
//  XPYDatabaseManager.mm
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYDatabaseManager.h"
#import "XPYBookModel.h"
#import "XPYChapterModel.h"

static NSString * const kXPYReaderDatabaseName = @"XPYReaderDatabase";

@implementation XPYDatabaseManager

+ (instancetype)sharedInstance {
    static XPYDatabaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XPYDatabaseManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 创建数据库
        self.database = [[WCTDatabase alloc] initWithPath:[XPYDocumentDirectory stringByAppendingPathComponent:kXPYReaderDatabaseName]];
        // 建表（看书记录表和章节内容表）
        [self.database createTableAndIndexesOfName:XPYReadRecordTable withClass:[XPYBookModel class]];
        [self.database createTableAndIndexesOfName:XPYChapterTable withClass:[XPYChapterModel class]];
    }
    return self;
}

@end

