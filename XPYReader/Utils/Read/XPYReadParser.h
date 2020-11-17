//
//  XPYReadParser.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//  内容解析相关

#import <Foundation/Foundation.h>

@class XPYChapterPageModel, XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadParser : NSObject

/// 章节名富文本属性
+ (NSDictionary *)chapterNameAttributes;

/// 章节内容富文本属性
+ (NSDictionary *)chapterContentAttributes;

/// 获取富文本章节内容
/// @param content 章节原始内容
/// @param chapterName 章节名
+ (NSAttributedString *)chapterAttributedContentWithChapterContent:(NSString *)content chapterName:(NSString *)chapterName;

/// 解析章节内容返回章节分页信息
/// @param content 内容
/// @param chapterName 章节名
+ (NSArray <XPYChapterPageModel *> *)parseChapterWithChapterContent:(NSString *)content chapterName:(NSString *)chapterName;

/// 解析本地书
/// @param filePath 本地书路径
/// @param success 成功回调（章节数组）
/// @param failure 失败回调
+ (void)parseLocalBookWithFilePath:(NSString *)filePath success:(void (^)(NSArray<XPYChapterModel *> *chapters))success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
