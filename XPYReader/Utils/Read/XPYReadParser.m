//
//  XPYReadParser.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadParser.h"

#import "XPYChapterPageModel.h"

#import <CoreText/CoreText.h>

@implementation XPYReadParser

+ (NSDictionary *)chapterNameAttributes {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSForegroundColorAttributeName] = [XPYReadConfigManager sharedInstance].currentTextColor;
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:[XPYReadConfigManager sharedInstance].fontSize + 5];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.paragraphSpacing = 0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    return attributes;
}

+ (NSDictionary *)chapterContentAttributes {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSForegroundColorAttributeName] = [XPYReadConfigManager sharedInstance].currentTextColor;
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:[XPYReadConfigManager sharedInstance].fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [[XPYReadConfigManager sharedInstance].lineSpacing floatValue];
    paragraphStyle.paragraphSpacing = [[XPYReadConfigManager sharedInstance].paragraphSpacing floatValue];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    return attributes;
}

+ (NSAttributedString *)chapterAttributedContentWithChapterContent:(NSString *)content chapterName:(NSString *)chapterName {
    // 章节名添加换行
    NSString *chapterNameString = [NSString stringWithFormat:@"\n%@\n\n", chapterName];
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:chapterNameString attributes:[self chapterNameAttributes]];
    content = [self resetContent:content];
    NSMutableAttributedString *chapterContentAttributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:[self chapterContentAttributes]];
    // 拼接章节名和章节内容
    [contentAttributedString appendAttributedString:chapterContentAttributedString];
    return contentAttributedString;
}

+ (NSArray<XPYChapterPageModel *> *)parseChapterWithChapterContent:(NSString *)content chapterName:(NSString *)chapterName {
    if (XPYIsEmptyObject(content)) {
        return nil;
    }
    NSAttributedString *contentAttributedString = [self chapterAttributedContentWithChapterContent:content chapterName:chapterName];
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)contentAttributedString);
    CGPathRef pathRef = CGPathCreateWithRect(XPYReadViewBounds, NULL);
    
    CFRange range = CFRangeMake(0, 0);
    // 当前文字位置
    NSInteger currentLocation = 0;
    NSMutableArray *pageRanges = [[NSMutableArray alloc] init];
    while (range.location + range.length < contentAttributedString.length) {
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(currentLocation, 0), pathRef, NULL);
        range = CTFrameGetVisibleStringRange(frameRef);
        // 保存分割位置
        [pageRanges addObject:[NSValue valueWithRange:NSMakeRange(currentLocation, range.length)]];
        // 当前文字位置递增
        currentLocation += range.length;
        if (frameRef) {
            CFRelease(frameRef);
        }
    }
    CGPathRelease(pathRef);
    CFRelease(framesetterRef);
    NSMutableArray <XPYChapterPageModel *> *pageModels = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageRanges.count; i ++) {
        XPYChapterPageModel *pageModel = [[XPYChapterPageModel alloc] init];
        NSRange range = [pageRanges[i] rangeValue];
        NSAttributedString *content = [contentAttributedString attributedSubstringFromRange:range];
        pageModel.pageIndex = i;
        pageModel.pageRange = range;
        pageModel.pageContent = content;
        
        // contentHeight和extraHeaderHeight只在上下滚动翻页模式使用
        pageModel.contentHeight = [self heightOfAttributedString:content];
        if (i == 0) {
            // 第一页
            pageModel.extraHeaderHeight = 0;
        } else if ([content.string hasPrefix:@"　　"]) {
            // 开头存在两个空格，则为新的一段开始，额外头部高度为段间距
            pageModel.extraHeaderHeight = [[XPYReadConfigManager sharedInstance].paragraphSpacing floatValue];
        } else {
            // 额外头部高度为行间距
            pageModel.extraHeaderHeight = [[XPYReadConfigManager sharedInstance].lineSpacing floatValue];
        }
        [pageModels addObject:pageModel];
    }
    return pageModels;
}

/// 处理章节内容
/// @param content 内容
+ (NSString *)resetContent:(NSString *)content {
    if (!content || content.length == 0) {
        return @"";
    }
    // 替换单换行
    content = [content stringByReplacingOccurrencesOfString:@"r" withString:@""];
    
    // 替换换行和多个换行（换行加空格）
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\s*\\n+\\s*" options:NSRegularExpressionCaseInsensitive error:nil];
    content = [regularExpression stringByReplacingMatchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, content.length) withTemplate:@"\n　　"];
    
    // 去掉首尾空格和换行
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 章节开头添加空格
    content = [@"　　" stringByAppendingString:content];
    
    return content;
}

/// 获取内容高度
/// @param attributedString 内容
+ (CGFloat)heightOfAttributedString:(NSAttributedString *)attributedString {
    if (XPYIsEmptyObject(attributedString)) {
        return 0;
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    // 这里的高要设置足够大
    CGFloat height = 10000;
    CGRect drawingRect = CGRectMake(0, 0, XPYReadViewWidth, height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), lineOrigins);
    // 最后一行原点y坐标加最后一行下行行高跟行距
    CGFloat heightValue = 0;
    // 最后一行line的原点y坐标
    CGFloat lineY = (CGFloat)lineOrigins[CFArrayGetCount(lines)-1].y;
    // 上行行高
    CGFloat lastAscent = 0;
    // 下行行高
    CGFloat lastDescent = 0;
    // 行距
    CGFloat lastLeading = 0;
    CTLineRef lastLine = CFArrayGetValueAtIndex(lines, CFArrayGetCount(lines)-1);
    CTLineGetTypographicBounds(lastLine, &lastAscent, &lastDescent, &lastLeading);
    // height - lineY为除去最后一行的字符原点以下的高度，descent + leading为最后一行不包括上行行高的字符高度
    heightValue = height - lineY + (CGFloat)(fabs(lastDescent) + lastLeading);
    heightValue = ceilf(heightValue);
    return heightValue;
}

@end
