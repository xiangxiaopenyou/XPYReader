//
//  XPYNetworkService+Chapter.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYNetworkService (Chapter)

/// 获取书籍章节信息（不包括章节内容）
/// @param bookId 书籍ID
/// @param success 成功回调
/// @param failure 失败回调
- (void)bookChaptersWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

/// 获取章节文字内容
/// @param bookId 书籍ID
/// @param chapterId 章节ID
/// @param success 成功回调
/// @param failure 失败回调
- (void)chapterContentWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
