//
//  XPYDatabaseManager.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const XPYReadRecordTable = @"read";
static NSString * const XPYChapterTable = @"chapter";

@interface XPYDatabaseManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) WCTDatabase *database;

@end

NS_ASSUME_NONNULL_END
