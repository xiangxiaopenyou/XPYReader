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
/// 护眼模式
@property (nonatomic, strong) UIButton *safeReadButton;
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
    self.backgroundColor = XPYColorFromHex(0x232428);
    
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
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = XPYColorFromHex(0x232428);
    [self addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
        make.height.mas_offset(60);
        make.width.equalTo(self.mas_width).multipliedBy(0.333);
    }];
    [view1 addSubview:self.safeReadButton];
    [self.safeReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(80, 60));
        make.center.equalTo(view1);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = XPYColorFromHex(0x232428);
    [self addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view1.mas_trailing);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
        make.height.mas_offset(60);
        make.width.equalTo(self.mas_width).multipliedBy(0.333);
    }];
    [view2 addSubview:self.autoReadButton];
    [self.autoReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(80, 60));
        make.center.equalTo(view2);
    }];
    
    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = XPYColorFromHex(0x232428);
    [self addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view2.mas_trailing);
        make.trailing.equalTo(self.mas_trailing);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
        make.height.mas_offset(60);
    }];
    [view3 addSubview:self.orientationButton];
    [self.orientationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(80, 60));
        make.center.equalTo(view3);
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
        _fontView.backgroundColor = XPYColorFromHex(0x232428);
    }
    return _fontView;
}
- (UIView *)spacingView {
    if (!_spacingView) {
        _spacingView = [[UIView alloc] initWithFrame:CGRectZero];
        _spacingView.backgroundColor = XPYColorFromHex(0x232428);
    }
    return _spacingView;
}
- (UIButton *)safeReadButton {
    if (!_safeReadButton) {
        _safeReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_safeReadButton setImage:[UIImage imageNamed:@"read_eye_unselected"] forState:UIControlStateNormal];
        [_safeReadButton setImage:[UIImage imageNamed:@"read_eye_selected"] forState:UIControlStateSelected];
        [_safeReadButton setTitle:@"护眼模式" forState:UIControlStateNormal];
        _safeReadButton.titleLabel.font = FontRegular(11);
        [_safeReadButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_safeReadButton setTitleColor:XPYColorFromHex(0xFF5050) forState:UIControlStateSelected];
        [_safeReadButton addTarget:self action:@selector(safeReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _safeReadButton;
}
- (UIButton *)autoReadButton {
    if (!_autoReadButton) {
        _autoReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_autoReadButton setImage:[UIImage imageNamed:@"auto_read"] forState:UIControlStateNormal];
        [_autoReadButton setTitle:@"自动阅读" forState:UIControlStateNormal];
        _autoReadButton.titleLabel.font = FontRegular(11);
        [_autoReadButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_autoReadButton addTarget:self action:@selector(autoReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoReadButton;
}
- (UIButton *)orientationButton {
    if (!_orientationButton) {
        _orientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_orientationButton setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        [_orientationButton setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateSelected];
        [_orientationButton setTitle:@"竖屏" forState:UIControlStateNormal];
        [_orientationButton setTitle:@"横屏" forState:UIControlStateSelected];
        _orientationButton.titleLabel.font = FontRegular(11);
        [_orientationButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_orientationButton addTarget:self action:@selector(orientationChangedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _orientationButton;
}

@end
