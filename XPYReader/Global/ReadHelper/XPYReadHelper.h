//
//  XPYReadHelper.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/12.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadHelper : NSObject

/// 阅读
/// @param bookModel 书籍
+ (void)readWithBook:(XPYBookModel *)bookModel;

/// 获取书籍章节信息准备阅读
/// @param bookModel 书籍模型
/// @param success 获取信息成功回调
/// @param failure 获取信息失败回调
+ (void)readyForReadingWithBook:(XPYBookModel *)bookModel success:(void (^)(XPYBookModel *book))success failure:(void (^)(NSString *tip))failure;

/// 添加书籍到书架
/// @param bookModel 书籍模型
/// @param complete 完成回调
+ (void)addToBookStackWithBook:(XPYBookModel *)bookModel complete:(void (^)(void))complete;

/// 书籍移出书架
/// @param bookModel 书籍模型
/// @param complete 完成回调
+ (void)removeFormBookStackWithBook:(XPYBookModel *)bookModel complete:(void (^)(void))complete;

/// 用户登录时同步本地书架和阅读记录
/// @param complete 完成回调
+ (void)synchronizeStackBooksAndReadRecordsComplete:(void (^)(void))complete;

@end

NS_ASSUME_NONNULL_END
