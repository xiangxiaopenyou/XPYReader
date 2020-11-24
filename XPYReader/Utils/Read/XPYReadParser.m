//
//  XPYReadParser.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadParser.h"

#import "XPYChapterPageModel.h"
#import "XPYChapterModel.h"

#import <CoreText/CoreText.h>

/// 本地书分章节正则表达
static NSString * const kParseLocalBookPattern = @"(\\s+?)([#☆、【0-9]{0,10})(第[0-9零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟\\s]{1,10}[章节回集卷])(.*)";

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
    paragraphStyle.lineSpacing = [XPYReadConfigManager sharedInstance].spacingLevel * 2.0;
    paragraphStyle.paragraphSpacing = [XPYReadConfigManager sharedInstance].spacingLevel * 3.0;
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
        @autoreleasepool {
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
                pageModel.extraHeaderHeight = [XPYReadConfigManager sharedInstance].spacingLevel * 3.0;
            } else {
                // 额外头部高度为行间距
                pageModel.extraHeaderHeight = [XPYReadConfigManager sharedInstance].spacingLevel * 2.0;
            }
            [pageModels addObject:pageModel];
        };
    }
    return pageModels;
}

+ (void)parseLocalBookWithFilePath:(NSString *)filePath success:(void (^)(NSArray<XPYChapterModel *> * _Nonnull chapters))success failure:(XPYFailureHandler)failure {
    if (!filePath) {
        !failure ?: failure([NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSUnderlyingErrorKey : @"文件路径为空"}]);
        return;
    }
    NSString *content = [self contentWithFilePath:filePath];
    if (XPYIsEmptyObject(content)) {
        !failure ?: failure([NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSUnderlyingErrorKey : @"书籍内容为空或者书籍格式错误"}]);
        return;
    }
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:kParseLocalBookPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [expression matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    NSMutableArray *chapters = [[NSMutableArray alloc] init];
    if (matches.count == 0) {
        // 全书分为一章
        XPYChapterModel *chapter = [[XPYChapterModel alloc] init];
        chapter.chapterId = @"1000000";
        chapter.chapterIndex = 1;
        chapter.chapterName = @"开始";
        chapter.content = content;
        [chapters addObject:chapter];
    } else {
        // 当前标题在全文中的位置
        NSRange currentRange = NSMakeRange(0, 0);
        // 当前章节编号
        NSInteger chapterIndex = 1;
        // 循环处理章节
        for (NSInteger i = 0; i < matches.count; i++) {
            @autoreleasepool {  // 自动释放池保证瞬时内存不会过高
                NSTextCheckingResult *result = matches[i];
                // 下一个标题在全文中的位置
                NSRange resultRange = result.range;
                // 截取两个标题之间内容为当前章节内容
                NSString *chapterContent = [content substringWithRange:NSMakeRange(currentRange.location + currentRange.length, resultRange.location - currentRange.location - currentRange.length)];
                if (!XPYIsEmptyObject(chapterContent) && resultRange.length <= 70) {
                    // 章节内容不为空并且章节标题长度不超过70
                    XPYChapterModel *chapterModel = [[XPYChapterModel alloc] init];
                    chapterModel.chapterIndex = chapterIndex;
                    chapterModel.chapterId = [NSString stringWithFormat:@"%@", @(1000000 + chapterIndex)];
                    chapterModel.chapterName = (chapterIndex == 1) ? @"开始" : [[content substringWithRange:currentRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    chapterModel.content = [self resetContent:chapterContent];
                    [chapters addObject:chapterModel];
                    chapterIndex += 1;
                    currentRange = resultRange;
                }
            };
        }
        NSString *endChapterContent = [content substringWithRange:NSMakeRange(currentRange.location + currentRange.length, content.length - currentRange.location - currentRange.length)];
        if (!XPYIsEmptyObject(endChapterContent)) {
            // 最后一章
            XPYChapterModel *endChapterModel = [[XPYChapterModel alloc] init];
            endChapterModel.chapterIndex = chapterIndex;
            endChapterModel.chapterId = [NSString stringWithFormat:@"%@", @(1000000 + chapterIndex)];
            endChapterModel.chapterName = [[content substringWithRange:currentRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            endChapterModel.content = [self resetContent:endChapterContent];
            [chapters addObject:endChapterModel];
        }
    }
    if (chapters.count > 0 && success) {
        success(chapters);
    }
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

/// 获取本地书籍文件内容
/// @param filePath 文件路径
+ (NSString *)contentWithFilePath:(NSString *)filePath {
    // 一些热门的文件编码，几乎可以满足所有的文件，可自行添加其他的
    NSArray *encodings = @[
        @(NSUTF8StringEncoding),
        @(0x80000632),
        @(0x80000631),
        @(kCFStringEncodingGB_2312_80),
        @(kCFStringEncodingHZ_GB_2312),
        @(kCFStringEncodingMacChineseSimp),
        @(kCFStringEncodingDOSChineseSimplif),
        @(kCFStringEncodingGB_18030_2000),
        @(NSUTF16StringEncoding),
        @(NSUTF16LittleEndianStringEncoding),
        @(NSUTF16BigEndianStringEncoding),
        @(NSUTF32StringEncoding),
        @(NSUTF32LittleEndianStringEncoding),
        @(NSUTF32BigEndianStringEncoding)
    ];
    NSString *result = nil;
    for (NSInteger i = 0; i < encodings.count; i++) {
        unsigned int encoding = [encodings[i] unsignedIntValue];
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:CFStringConvertEncodingToNSStringEncoding(encoding) error:&error];
        if (!error && !XPYIsEmptyObject(content)) {
            result = content;
            break;
        }
    }
    return result;
}

@end

