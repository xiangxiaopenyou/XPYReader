//
//  XPYReadView.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadView.h"
#import <CoreText/CoreText.h>

@interface XPYReadView ()

@property (nonatomic, copy) NSAttributedString *contentString;

@end

@implementation XPYReadView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
    }
    return self;
}

#pragma mark - Instance methods
- (void)setupContent:(NSAttributedString *)content {
    self.contentString = [content copy];
    [self setNeedsDisplay];
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.contentString);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(contextRef, 1.0, - 1.0);
    CGPathRef pathRef = CGPathCreateWithRect(self.bounds, NULL);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), pathRef, NULL);
    CTFrameDraw(frameRef, contextRef);
    CGPathRelease(pathRef);
    CFRelease(frameSetterRef);
    CFRelease(frameRef);
}

- (NSAttributedString *)contentString {
    if (!_contentString) {
        _contentString = [[NSAttributedString alloc] initWithString:@""];
    }
    return _contentString;
}

@end
