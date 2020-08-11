//
//  XPYReadParser.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadParser : NSObject

/// 章节名文字属性
+ (NSDictionary *)chapterNameAttributes;

/// 章节内容文字属性
+ (NSDictionary *)chapterContentAttributes;

/// 解析章节内容
/// @param content 内容
/// @param chapterName 章节名
/// @param bounds 显示区域
/// @param complete 完成解析回调
+ (void)parseChapterWithContent:(NSString *)content
                    chapterName:(NSString *)chapterName
                         bounds:(CGRect)bounds
                       complete:(void (^)(NSAttributedString *chapterContent, NSArray *pageRanges))complete;

/// 获取单页内容
/// @param chapterContent 章节内容
/// @param page 页码
/// @param pageRanges 页码内容范围数组
+ (NSAttributedString *)pageContentWithChapterContent:(NSAttributedString *)chapterContent page:(NSInteger)page pageRanges:(NSArray *)pageRanges;

@end

NS_ASSUME_NONNULL_END
