//
//  XPYReadRecordManager.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//  阅读记录数据管理

#import <Foundation/Foundation.h>

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadRecordManager : NSObject

/// 插入或者替换数据
/// @param bookModel 数据模型
+ (void)insertOrReplaceRecordWithModel:(XPYBookModel *)bookModel;

/// 根据bookId获取阅读记录
/// @param bookId 书籍ID
+ (XPYBookModel *)recordWithBookId:(NSString *)bookId;


@end

NS_ASSUME_NONNULL_END
