//
//  XPYReadView.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadView.h"

#import "XPYChapterModel.h"
#import "XPYChapterPageModel.h"
#import "XPYParagraphModel.h"

#import "XPYReadParser.h"

#import "UIGestureRecognizer+XPYTag.h"

#import <CoreText/CoreText.h>

@interface XPYReadView ()

/// 长按选择手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
/// 单击取消手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) XPYChapterModel *chapterModel;
@property (nonatomic, strong) XPYChapterPageModel *pageModel;

/// 选中行数组
@property (nonatomic, copy) NSArray *selectedRects;

@end

@implementation XPYReadView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
        
        [self addGestureRecognizer:self.longPress];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(contextRef, 1.0, - 1.0);
    CTFrameRef frameRef = [XPYReadParser frameRefWithAttributedString:self.pageModel.pageContent rect:self.bounds];
    // 处理选中行
    if (self.selectedRects.count > 0) {
        for (id value in self.selectedRects) {
            // 画出选中行矩形
            CGRect rect = [value CGRectValue];
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            // 设置选中颜色（暂时设置为字体颜色加0.5透明度）
            [[[XPYReadConfigManager sharedInstance].currentTextColor colorWithAlphaComponent:0.5] setFill];
            CGPathAddRect(mutablePath, NULL, rect);
            CGContextAddPath(contextRef, mutablePath);
            CGContextFillPath(contextRef);
            CGPathRelease(mutablePath);
        }
    }
    CTFrameDraw(frameRef, contextRef);
    CFRelease(frameRef);
}

#pragma mark - Instance methods
- (void)setupPageModel:(XPYChapterPageModel *)pageModel chapter:(XPYChapterModel *)chapterModel {
    self.pageModel = pageModel;
    self.chapterModel = chapterModel;
    [self setNeedsDisplay];
}

#pragma mark - Event response
- (void)longPressAction:(UILongPressGestureRecognizer *)press {
    // 触摸点在当前视图的位置
    CGPoint point = [press locationInView:self];
    // 触摸点在Window视图的位置
    // CGPoint pointInWindow = [press locationInView:XPYKeyWindow];
    switch (press.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
        case UIGestureRecognizerStateChanged: {
            
        }
            break;
        case UIGestureRecognizerStateEnded: {
            // 获取当前页面CTFrame
            CTFrameRef frameRef = [XPYReadParser frameRefWithAttributedString:self.pageModel.pageContent rect:self.bounds];
            // 获取触摸点所在行
            NSRange lineRange = [XPYReadParser touchLineRangeWithPoint:point frameRef:frameRef];
            if (lineRange.location == NSNotFound) {
                CFRelease(frameRef);
                return;
            }
            // 获取页面段落
            NSArray <XPYParagraphModel *> *paragraphs = [XPYReadParser paragraphsWithPageModel:self.pageModel chapterName:self.chapterModel.chapterName];
            // 逆序遍历段落
            [paragraphs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XPYParagraphModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.range.location <= lineRange.location && (obj.range.location + obj.range.length) >= (lineRange.location + lineRange.length)) {
                    // 找到触摸点所在段
                    // 获取选中段落范围
                    self.selectedRects = [XPYReadParser rectsWithRange:obj.range content:self.pageModel.pageContent.string frameRef:frameRef];
                    if (self.selectedRects.count > 0) {
                        // 设置单击手势有效
                        self.singleTap.enabled = YES;
                    }
                    CFRelease(frameRef);
                    // 重绘
                    [self setNeedsDisplay];
                    *stop = YES;
                }
            }];
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
        }
            break;
        default:
            break;
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    // 单击取消当前选中内容
    self.selectedRects = nil;
    // 设置单击手势失效
    self.singleTap.enabled = NO;
    // 重绘
    [self setNeedsDisplay];
}

#pragma mark - Getters
- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPress.tag = XPYReadViewLongPressTag;
    }
    return _longPress;
}
- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTap.tag = XPYReadViewSingleTapTag;
        _singleTap.enabled = NO;
    }
    return _singleTap;
}

@end
