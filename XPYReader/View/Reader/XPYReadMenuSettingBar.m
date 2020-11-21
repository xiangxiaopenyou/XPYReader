//
//  XPYReadMenuSettingBar.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/25.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenuSettingBar.h"

@interface XPYReadMenuSettingBar ()

/// 字体相关父视图
@property (nonatomic, strong) UIView *fontView;
/// 字号减
@property (nonatomic, strong) UIButton *minusFontSizeButton;
/// 字号加
@property (nonatomic, strong) UIButton *plusFontSizeButton;
/// 字号
@property (nonatomic, strong) UILabel *fontSizeLabel;
/// 段/行间距相关父视图
@property (nonatomic, strong) UIView *spacingView;
/// 自动阅读
@property (nonatomic, strong) UIButton *autoReadButton;
/// 横屏
@property (nonatomic, strong) UIButton *orientationButton;

@end

@implementation XPYReadMenuSettingBar

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    return self;
}

#pragma mark - UI
- (void)configureUI {
    self.backgroundColor = XPYColorFromHex(0x222222);
    
    [self addSubview:self.fontView];
    [self.fontView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.top.equalTo(self.mas_top).mas_offset(20);
        make.size.mas_equalTo(CGSizeMake(XPYScreenWidth, 30));
    }];
    
    [self addSubview:self.spacingView];
    [self.spacingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(XPYScreenWidth, 30));
        make.top.equalTo(self.mas_top).offset(68);
    }];
    
    
    [self addSubview:self.autoReadButton];
    [self.autoReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(80, 60));
        make.centerX.equalTo(self.mas_centerX).multipliedBy(0.5);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
    }];
    
    [self addSubview:self.orientationButton];
    [self.orientationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(80, 60));
        make.centerX.equalTo(self.mas_centerX).multipliedBy(1.5);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
    }];
}

#pragma mark - Instance methods
- (void)updateViewsConstraints {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat spacingViewTopConstraints = orientation == UIInterfaceOrientationPortrait ? 68 : 20;
    [self.spacingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).mas_offset(spacingViewTopConstraints);
    }];
}

#pragma mark - Actions
- (void)safeReadAction {
    
}
- (void)autoReadAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingBarClickAutoRead)]) {
        [self.delegate settingBarClickAutoRead];
    }
}
- (void)orientationChangedAction {
    
}

#pragma mark - Getters
- (UIView *)fontView {
    if (!_fontView) {
        _fontView = [[UIView alloc] initWithFrame:CGRectZero];
        _fontView.backgroundColor = XPYColorFromHex(0x222222);
    }
    return _fontView;
}
- (UIView *)spacingView {
    if (!_spacingView) {
        _spacingView = [[UIView alloc] initWithFrame:CGRectZero];
        _spacingView.backgroundColor = XPYColorFromHex(0x222222);
    }
    return _spacingView;
}
- (UIButton *)autoReadButton {
    if (!_autoReadButton) {
        _autoReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_autoReadButton setTitle:@"自动阅读模式" forState:UIControlStateNormal];
        _autoReadButton.titleLabel.font = FontRegular(11);
        [_autoReadButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_autoReadButton addTarget:self action:@selector(autoReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoReadButton;
}
- (UIButton *)orientationButton {
    if (!_orientationButton) {
        _orientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_orientationButton setTitle:@"竖屏模式" forState:UIControlStateNormal];
        [_orientationButton setTitle:@"横屏模式" forState:UIControlStateSelected];
        _orientationButton.titleLabel.font = FontRegular(11);
        [_orientationButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_orientationButton addTarget:self action:@selector(orientationChangedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _orientationButton;
}

@end
