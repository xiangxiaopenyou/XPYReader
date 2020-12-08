//
//  XPYTransitionManager.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/10/16.
//  Copyright © 2020 xiang. All rights reserved.
//  转场动画管理类

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYTransitionManager : NSObject <UINavigationControllerDelegate>

+ (instancetype)shareManager;

@property (nonatomic, strong, nullable) UIView *pushView;
@property (nonatomic, strong, nullable) UIView *popView;

@end

NS_ASSUME_NONNULL_END
