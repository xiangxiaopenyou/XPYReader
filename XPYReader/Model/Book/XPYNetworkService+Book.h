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

/// 获取书籍章节信息（不包括章节内容）
/// @param bookId 书籍ID
/// @param success 成功回调
/// @param failure 失败回调
- (void)bookChaptersWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
