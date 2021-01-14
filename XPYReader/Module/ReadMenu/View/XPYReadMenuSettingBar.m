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
/// 行间距减
@property (nonatomic, strong) UIButton *minusSpacingButton;
/// 行间距加
@property (nonatomic, strong) UIButton *plusSpacingButton;
/// 行间距
@property (nonatomic, strong) UILabel *spacingLabel;
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
        make.height.mas_offset(30);
        make.width.equalTo(self.mas_width).multipliedBy(0.5);
    }];
    
    [self.fontView addSubview:self.minusFontSizeButton];
    [self.minusFontSizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.fontView);
        make.width.equalTo(self.fontView.mas_width).multipliedBy(0.3);
    }];
    
    [self.fontView addSubview:self.plusFontSizeButton];
    [self.plusFontSizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(self.fontView);
        make.width.equalTo(self.fontView.mas_width).multipliedBy(0.3);
    }];
    
    [self.fontView addSubview:self.fontSizeLabel];
    [self.fontSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.minusFontSizeButton.mas_trailing);
        make.trailing.equalTo(self.plusFontSizeButton.mas_leading);
        make.bottom.top.equalTo(self.fontView);
    }];
    
    [self addSubview:self.spacingView];
    [self.spacingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing);
        make.top.equalTo(self.mas_top).offset(20);
        make.height.mas_offset(30);
        make.width.equalTo(self.mas_width).multipliedBy(0.5);
    }];
    
    [self.spacingView addSubview:self.minusSpacingButton];
    [self.minusSpacingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.spacingView);
        make.width.equalTo(self.spacingView.mas_width).multipliedBy(0.3);
    }];
    
    [self.spacingView addSubview:self.plusSpacingButton];
    [self.plusSpacingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(self.spacingView);
        make.width.equalTo(self.spacingView.mas_width).multipliedBy(0.3);
    }];
    
    [self.spacingView addSubview:self.spacingLabel];
    [self.spacingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.minusSpacingButton.mas_trailing);
        make.trailing.equalTo(self.plusSpacingButton.mas_leading);
        make.bottom.top.equalTo(self.spacingView);
    }];
    
    [self addSubview:self.autoReadButton];
    [self.autoReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(100, 60));
        make.centerX.equalTo(self.mas_centerX).multipliedBy(0.5);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
    }];
    
    [self addSubview:self.orientationButton];
    [self.orientationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(100, 60));
        make.centerX.equalTo(self.mas_centerX).multipliedBy(1.5);
        make.top.equalTo(self.spacingView.mas_bottom).mas_offset(10);
    }];
}

#pragma mark - Private methods
- (void)fontSizeDidChangeWithSize:(NSInteger)size {
    [[XPYReadConfigManager sharedInstance] updateFontSizeWithSize:size];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%@", @(size)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingBarDidChangeFontSize)]) {
        [self.delegate settingBarDidChangeFontSize];
    }
}
- (void)spacingLevelDidChangeWithLevel:(NSInteger)level {
    [[XPYReadConfigManager sharedInstance] updateSpacingLevel:level];
    self.spacingLabel.text = [NSString stringWithFormat:@"%@", @(level)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingBarDidChangeSpacing)]) {
        [self.delegate settingBarDidChangeSpacing];
    }
}

#pragma mark - Event response
- (void)autoReadAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingBarClickAutoRead)]) {
        [self.delegate settingBarClickAutoRead];
    }
}
- (void)orientationChangedAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingBarDidChangeAllowLandscape:)]) {
        self.orientationButton.selected = !self.orientationButton.selected;
        [self.delegate settingBarDidChangeAllowLandscape:self.orientationButton.selected];
        [MBProgressHUD xpy_showTips:self.orientationButton.isSelected ? @"阅读器将跟随系统横竖屏" : @"阅读页已经关闭横屏"];
    }
}
- (void)minusFontSizeAction {
    NSInteger currentSize = [XPYReadConfigManager sharedInstance].fontSize;
    if (currentSize <= 13) {
        return;
    }
    [self fontSizeDidChangeWithSize:currentSize - 2];
}
- (void)plusFontSizeAction {
    NSInteger currentSize = [XPYReadConfigManager sharedInstance].fontSize;
    if (currentSize >= 25) {
        return;
    }
    [self fontSizeDidChangeWithSize:currentSize + 2];
}

- (void)minusSpacingAction {
    NSInteger currentSpacingLevel = [XPYReadConfigManager sharedInstance].spacingLevel;
    if (currentSpacingLevel <= 1) {
        return;
    }
    [self spacingLevelDidChangeWithLevel:currentSpacingLevel - 1];
}

- (void)plusSpacingAction {
    NSInteger currentSpacingLevel = [XPYReadConfigManager sharedInstance].spacingLevel;
    if (currentSpacingLevel >= 5) {
        return;
    }
    [self spacingLevelDidChangeWithLevel:currentSpacingLevel + 1];
}

#pragma mark - Getters
- (UIView *)fontView {
    if (!_fontView) {
        _fontView = [[UIView alloc] initWithFrame:CGRectZero];
        _fontView.backgroundColor = XPYColorFromHex(0x222222);
    }
    return _fontView;
}
- (UIButton *)minusFontSizeButton {
    if (!_minusFontSizeButton) {
        _minusFontSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_minusFontSizeButton setTitle:@"字号-" forState:UIControlStateNormal];
        [_minusFontSizeButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _minusFontSizeButton.titleLabel.font = XPYFontRegular(11);
        _minusFontSizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_minusFontSizeButton addTarget:self action:@selector(minusFontSizeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minusFontSizeButton;;
}
- (UIButton *)plusFontSizeButton {
    if (!_plusFontSizeButton) {
        _plusFontSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusFontSizeButton setTitle:@"字号+" forState:UIControlStateNormal];
        [_plusFontSizeButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _plusFontSizeButton.titleLabel.font = XPYFontRegular(11);
        _plusFontSizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_plusFontSizeButton addTarget:self action:@selector(plusFontSizeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusFontSizeButton;;
}
- (UILabel *)fontSizeLabel {
    if (!_fontSizeLabel) {
        _fontSizeLabel = [[UILabel alloc] init];
        _fontSizeLabel.textColor = [UIColor yellowColor];
        _fontSizeLabel.font = XPYFontRegular(14);
        _fontSizeLabel.textAlignment = NSTextAlignmentCenter;
        _fontSizeLabel.text = [NSString stringWithFormat:@"%@", @([XPYReadConfigManager sharedInstance].fontSize)];
    }
    return _fontSizeLabel;
}
- (UIView *)spacingView {
    if (!_spacingView) {
        _spacingView = [[UIView alloc] initWithFrame:CGRectZero];
        _spacingView.backgroundColor = XPYColorFromHex(0x222222);
    }
    return _spacingView;
}
- (UIButton *)minusSpacingButton {
    if (!_minusSpacingButton) {
        _minusSpacingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_minusSpacingButton setTitle:@"间距-" forState:UIControlStateNormal];
        [_minusSpacingButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _minusSpacingButton.titleLabel.font = XPYFontRegular(11);
        _minusSpacingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_minusSpacingButton addTarget:self action:@selector(minusSpacingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minusSpacingButton;;
}
- (UIButton *)plusSpacingButton {
    if (!_plusSpacingButton) {
        _plusSpacingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusSpacingButton setTitle:@"间距+" forState:UIControlStateNormal];
        [_plusSpacingButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _plusSpacingButton.titleLabel.font = XPYFontRegular(11);
        _plusSpacingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_plusSpacingButton addTarget:self action:@selector(plusSpacingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusSpacingButton;;
}
- (UILabel *)spacingLabel {
    if (!_spacingLabel) {
        _spacingLabel = [[UILabel alloc] init];
        _spacingLabel.textColor = [UIColor yellowColor];
        _spacingLabel.font = XPYFontRegular(14);
        _spacingLabel.textAlignment = NSTextAlignmentCenter;
        _spacingLabel.text = [NSString stringWithFormat:@"%@", @([XPYReadConfigManager sharedInstance].spacingLevel)];
    }
    return _spacingLabel;
}
- (UIButton *)autoReadButton {
    if (!_autoReadButton) {
        _autoReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_autoReadButton setTitle:@"自动阅读模式" forState:UIControlStateNormal];
        _autoReadButton.titleLabel.font = XPYFontRegular(11);
        [_autoReadButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_autoReadButton addTarget:self action:@selector(autoReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoReadButton;
}
- (UIButton *)orientationButton {
    if (!_orientationButton) {
        _orientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_orientationButton setTitle:@"跟随系统横竖屏(关)" forState:UIControlStateNormal];
        [_orientationButton setTitle:@"跟随系统横竖屏(开)" forState:UIControlStateSelected];
        _orientationButton.titleLabel.font = XPYFontRegular(11);
        [_orientationButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_orientationButton addTarget:self action:@selector(orientationChangedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _orientationButton;
}

@end
