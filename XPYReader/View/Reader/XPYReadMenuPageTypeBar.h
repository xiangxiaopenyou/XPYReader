//
//  XPYReadMenuPageTypeBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/20.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadMenuPageTypeBarDelegate <NSObject>

- (void)pageTypeBarDidSelectType;

@end

@interface XPYReadMenuPageTypeBar : UIView

@property (nonatomic, weak) id <XPYReadMenuPageTypeBarDelegate> delegate;

/// 更新按钮位置（横竖屏切换）
- (void)updateButtonsConstraints;

@end

NS_ASSUME_NONNULL_END
