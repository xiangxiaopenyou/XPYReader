//
//  XPYReadParser.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadParser.h"
#import "XPYReadConfigManager.h"

#import <CoreText/CoreText.h>

@implementation XPYReadParser

+ (NSDictionary *)chapterNameAttributes {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSForegroundColorAttributeName] = [XPYReadConfigManager sharedInstance].textColor;
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
    attributes[NSForegroundColorAttributeName] = [XPYReadConfigManager sharedInstance].textColor;
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:[XPYReadConfigManager sharedInstance].fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [XPYReadConfigManager sharedInstance].lineSpacing;
    paragraphStyle.paragraphSpacing = [XPYReadConfigManager sharedInstance].paragraphSpacing;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    return attributes;
}

+ (void)parseChapterWithContent:(NSString *)content chapterName:(NSString *)chapterName bounds:(CGRect)bounds complete:(void (^)(NSAttributedString * _Nonnull, NSArray * _Nonnull))complete {
    // 章节名添加换行
    NSString *chapterNameString = [NSString stringWithFormat:@"\n%@\n\n", chapterName];
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:chapterNameString attributes:[self chapterNameAttributes]];
    content = [self resetContent:content];
    NSMutableAttributedString *chapterContentAttributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:[self chapterContentAttributes]];
    // 拼接章节名和章节内容
    [contentAttributedString appendAttributedString:chapterContentAttributedString];
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)contentAttributedString);
    CGPathRef pathRef = CGPathCreateWithRect(bounds, NULL);
    
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
    if (complete) {
        complete(contentAttributedString, [pageRanges copy]);
    }
}

+ (NSAttributedString *)pageContentWithChapterContent:(NSAttributedString *)chapterContent page:(NSInteger)page pageRanges:(NSArray *)pageRanges {
    if (page >= pageRanges.count) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    NSRange range = [pageRanges[page] rangeValue];
    return [chapterContent attributedSubstringFromRange:range];
}

/// 处理章节内容
/// @param content 内容
+ (NSString *)resetContent:(NSString *)content {
    if (!content || content.length == 0) {
        content = @"";
    }
//    content = [content stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
//    content = [content stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
//    content = [content stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
//    content = [content stringByReplacingOccurrencesOfString:@"\0" withString:@""];
//    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 段落开头空格
    //content = [NSString stringWithFormat:@"%@%@", @"　　", content];
    //content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"\n　　"];
    return content;
}

@end
