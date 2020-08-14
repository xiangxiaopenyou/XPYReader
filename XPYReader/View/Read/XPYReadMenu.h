//
//  XPYReadMenu.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol XPYReadMenuDelegate <NSObject>

- (void)readMenuDidClickBack;

@end

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadMenu : NSObject

@property (nonatomic, weak) id <XPYReadMenuDelegate> delegate;

/// 唯一初始化方法
/// @param sourceView 需要展示Menu的视图，为空则设为KeyWindow
- (instancetype)initWithView:(UIView * _Nullable)sourceView;

/// 显示菜单
- (void)show;

/// 隐藏菜单
- (void)hidden;

@end

NS_ASSUME_NONNULL_END
