//
//  UIGestureRecognizer+XPYTag.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/12/1.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "UIGestureRecognizer+XPYTag.h"

#import <objc/runtime.h>

static const void *kXPYGestureRecognizerTagKey = &kXPYGestureRecognizerTagKey;

@implementation UIGestureRecognizer (XPYTag)

- (void)setTag:(NSUInteger)tag {
    objc_setAssociatedObject(self, kXPYGestureRecognizerTagKey, @(tag), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)tag {
    return [objc_getAssociatedObject(self, kXPYGestureRecognizerTagKey) integerValue];
}

@end
