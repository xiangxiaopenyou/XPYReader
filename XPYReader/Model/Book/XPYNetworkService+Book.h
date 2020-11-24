//
//  XPYNetworkService+Book.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYNetworkService (Book)

/**
 举例返回数据格式，data中可以是数组也可以是字典
 {
     "errno": 0,
     "msg": "ok",
     "data": [
         {
            "id": ""
            "book_id": "",
            "book_name": "",
            "pic": "",
            "author": "",
            "intro": "",
            "book_read_utime": ""
        }
     ]
 }
 **/

/// 书架默认书籍
- (void)stackBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 书城书籍列表
- (void)storeBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 书籍详情
- (void)bookDetailsRequestWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 同步书架书籍
/// @param booksString bookId拼接字符串
- (void)synchronizeStackBooksWithBooksString:(NSString *)booksString success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 同步阅读记录
/// @param records 记录数组（书籍）
- (void)synchronizeReadRecordWithRecords:(NSArray *)records success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
