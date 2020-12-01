//
//  UIGestureRecognizer+XPYTag.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/12/1.
//  Copyright © 2020 xiang. All rights reserved.
//  给手势关联一个tag属性

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (XPYTag)

@property (nonatomic, assign) NSUInteger tag;

@end

NS_ASSUME_NONNULL_END
