//
//  XPYReadMenuSettingBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/25.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadMenuSettingBarDelegate <NSObject>

/// 点击自动阅读
- (void)settingBarClickAutoRead;

/// 字体大小变化
- (void)settingBarDidChangeFontSize;

/// 间距大小变化
- (void)settingBarDidChangeSpacing;

/// 是否允许跟随系统横竖屏
- (void)settingBarDidChangeAllowLandscape:(BOOL)yesOrNo;

@end

@interface XPYReadMenuSettingBar : UIView

@property (nonatomic, weak) id <XPYReadMenuSettingBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
