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

/// 书架默认书籍
- (void)stackBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 书城书籍列表
- (void)storeBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 书籍详情
- (void)bookDetailsRequestWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
