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
/// @param bookModel 书籍模型
+ (void)insertOrReplaceRecordWithModel:(XPYBookModel *)bookModel;

/// 删除数据
/// @param bookModel 书籍模型
+ (void)deleteRecordWithModel:(XPYBookModel *)bookModel;

/// 删除所有阅读数据
+ (void)deleteAllReadRecords;

/// 根据bookId获取阅读记录
/// @param bookId 书籍ID
+ (XPYBookModel *)recordWithBookId:(NSString *)bookId;

/// 更新阅读时间
/// @param bookModel 书籍模型
+ (void)updateOpenTimeWithModel:(XPYBookModel *)bookModel;

/// 更新是否在书架状态
/// @param bookModel 书籍模型
+ (void)updateInStackStatusWithModel:(XPYBookModel *)bookModel;

/// 更新章节数量
/// @param bookId 书籍ID
/// @param count 数量
+ (void)updateChapterCountWithBookId:(NSString *)bookId count:(NSInteger)count;

/// 更新阅读记录
/// @param bookModel 书籍模型
+ (void)updateReadRecordWithModel:(XPYBookModel *)bookModel;

/// 获取所有在书架上的书籍
+ (NSArray *)allBooksInStack;

/// 获取所有阅读过的书籍
+ (NSArray *)allReadBooks;


@end

NS_ASSUME_NONNULL_END
