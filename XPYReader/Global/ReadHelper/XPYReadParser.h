//
//  XPYReadParser.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//  内容解析相关

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@class XPYChapterPageModel, XPYChapterModel, XPYParagraphModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadParser : NSObject

/// 章节名富文本属性
+ (NSDictionary *)chapterNameAttributes;

/// 章节内容富文本属性
+ (NSDictionary *)chapterContentAttributes;

/// 根据富文本和Rect获取CTFrame
/// @param attributedString 富文本
/// @param rect Rect
+ (nullable CTFrameRef)frameRefWithAttributedString:(NSAttributedString *)attributedString rect:(CGRect)rect;

/// 获取富文本章节内容
/// @param content 章节原始内容
/// @param chapterName 章节名
+ (NSAttributedString *)chapterAttributedContentWithChapterContent:(NSString *)content chapterName:(NSString *)chapterName;

/// 解析章节内容返回章节分页信息
/// @param content 内容
/// @param chapterName 章节名
+ (nullable NSArray <XPYChapterPageModel *> *)parseChapterWithChapterContent:(NSString *)content chapterName:(NSString *)chapterName;

/// 页面分段
/// @param pageModel 页面数据模型
/// @param chapterName 章节名
+ (nullable NSArray <XPYParagraphModel *> *)paragraphsWithPageModel:(XPYChapterPageModel *)pageModel chapterName:(NSString *)chapterName;

/// 获取触摸点所在行范围
/// @param point 触摸点
/// @param frameRef CTFrameRef
+ (NSRange)touchLineRangeWithPoint:(CGPoint)point frameRef:(CTFrameRef)frameRef;

/// 获取字符串覆盖的位置
/// @param range 文字范围
/// @param content 文字内容
/// @param frameRef CTFrameRef
+ (nullable NSArray *)rectsWithRange:(NSRange)range content:(NSString *)content frameRef:(CTFrameRef)frameRef;

/// 解析本地书
/// @param filePath 本地书路径
/// @param success 成功回调（章节数组）
/// @param failure 失败回调
+ (void)parseLocalBookWithFilePath:(NSString *)filePath success:(void (^)(NSArray<XPYChapterModel *> *chapters))success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
