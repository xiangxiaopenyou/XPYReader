//
//  XPYReadMenuAutoReadSettingBar.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/26.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenuAutoReadSettingBar.h"

@interface XPYReadMenuAutoReadSettingBar ()

/// 翻页速度显示
@property (nonatomic, strong) UILabel *speedLabel;
/// 减速按钮
@property (nonatomic, strong) UIButton *minusSpeedButton;
/// 加速按钮
@property (nonatomic, strong) UIButton *plusSpeedButton;
/// 模式切换（覆盖、滚屏）
@property (nonatomic, strong) UIButton *changeModeButton;
/// 退出自动翻页按钮
@property (nonatomic, strong) UIButton *exitAutoReadButton;

/// 阅读模式
@property (nonatomic, assign) XPYAutoReadMode mode;
/// 阅读速度
@property (nonatomic, assign) NSInteger speed;

@end

@implementation XPYReadMenuAutoReadSettingBar

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _mode = [XPYReadConfigManager sharedInstance].autoReadMode;
        _speed = [XPYReadConfigManager sharedInstance].autoReadSpeed;
        
        [self configureUI];
    }
    return self;
}

#pragma mark - UI
- (void)configureUI {
    self.backgroundColor = XPYColorFromHex(0x222222);
    
    [self addSubview:self.minusSpeedButton];
    [self.minusSpeedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).mas_offset(20);
        make.top.equalTo(self.mas_top).mas_offset(25);
        make.height.mas_offset(30);
        make.width.equalTo(self.mas_width).multipliedBy(0.25).mas_offset(- 20);
    }];
    
    [self addSubview:self.speedLabel];
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.minusSpeedButton.mas_trailing);
        make.top.equalTo(self.mas_top).mas_offset(25);
        make.height.mas_offset(30);
        make.width.equalTo(self.mas_width).multipliedBy(0.25).mas_offset(- 20);
    }];
    
    [self addSubview:self.plusSpeedButton];
    [self.plusSpeedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.speedLabel.mas_trailing);
        make.top.equalTo(self.mas_top).mas_offset(25);
        make.height.mas_offset(30);
        make.width.equalTo(self.mas_width).multipliedBy(0.25).mas_offset(- 20);
    }];
    
    [self addSubview:self.changeModeButton];
    [self.changeModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.plusSpeedButton.mas_trailing).mas_offset(20);
        make.trailing.equalTo(self.mas_trailing).mas_offset(- 20);
        make.top.equalTo(self.mas_top).mas_offset(25);
        make.height.mas_offset(30);
    }];
    
    [self addSubview:self.exitAutoReadButton];
    [self.exitAutoReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.plusSpeedButton.mas_bottom).mas_offset(20);
        make.size.mas_offset(CGSizeMake(120, 30));
    }];
}

#pragma mark - Private methods
- (void)changeSpeed:(NSInteger)speed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoReadSettingBarDidChangeReadSpeed:)]) {
        [self.delegate autoReadSettingBarDidChangeReadSpeed:speed];
        self.speedLabel.text = [NSString stringWithFormat:@"%@", @(speed)];
    }
}

#pragma mark - Event response
- (void)minusSpeedAction {
    NSInteger currentSpeed = [XPYReadConfigManager sharedInstance].autoReadSpeed;
    if (currentSpeed <= XPYMinAutoReadSpeed) {
        return;
    }
    [self changeSpeed:currentSpeed - 1];
}
- (void)plusSpeedAction {
    NSInteger currentSpeed = [XPYReadConfigManager sharedInstance].autoReadSpeed;
    if (currentSpeed >= XPYMaxAutoReadSpeed) {
        return;
    }
    [self changeSpeed:currentSpeed + 1];
}
- (void)changeModeAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoReadSettingBarDidChangeMode:)]) {
        XPYAutoReadMode mode = _mode == XPYAutoReadModeScroll ? XPYAutoReadModeCover : XPYAutoReadModeScroll;
        _mode = mode;
        // 更新当前按钮状态
        self.changeModeButton.selected = _mode == XPYAutoReadModeCover;
        [self.delegate autoReadSettingBarDidChangeMode:_mode];
    }
}
- (void)exitAutoReadAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoReadSettingBarDidClickExit)]) {
        [self.delegate autoReadSettingBarDidClickExit];
    }
}

#pragma mark - Getters
- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.font = XPYFontRegular(16);
        _speedLabel.textColor = [UIColor yellowColor];
        _speedLabel.textAlignment = NSTextAlignmentCenter;
        _speedLabel.text = [NSString stringWithFormat:@"%@", @(_speed)];
    }
    return _speedLabel;
}
- (UIButton *)minusSpeedButton {
    if (!_minusSpeedButton) {
        _minusSpeedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_minusSpeedButton setTitle:@"减速-" forState:UIControlStateNormal];
        [_minusSpeedButton setTitleColor:XPYColorFromHex(0x8F8F90) forState:UIControlStateNormal];
        _minusSpeedButton.layer.cornerRadius = 3;
        _minusSpeedButton.layer.borderColor = XPYColorFromHex(0x8F8F90).CGColor;
        _minusSpeedButton.layer.borderWidth = 1;
        _minusSpeedButton.titleLabel.font = XPYFontRegular(14);
        [_minusSpeedButton addTarget:self action:@selector(minusSpeedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minusSpeedButton;
}
- (UIButton *)plusSpeedButton {
    if (!_plusSpeedButton) {
        _plusSpeedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusSpeedButton setTitle:@"加速+" forState:UIControlStateNormal];
        [_plusSpeedButton setTitleColor:XPYColorFromHex(0x8F8F90) forState:UIControlStateNormal];
        _plusSpeedButton.layer.cornerRadius = 3;
        _plusSpeedButton.layer.borderColor = XPYColorFromHex(0x8F8F90).CGColor;
        _plusSpeedButton.layer.borderWidth = 1;
        _plusSpeedButton.titleLabel.font = XPYFontRegular(14);
        [_plusSpeedButton addTarget:self action:@selector(plusSpeedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusSpeedButton;
}
- (UIButton *)changeModeButton {
    if (!_changeModeButton) {
        _changeModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeModeButton.titleLabel.font = XPYFontRegular(14);
        [_changeModeButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_changeModeButton setTitle:@"自动覆盖模式" forState:UIControlStateSelected];
        [_changeModeButton setTitle:@"自动滚动模式" forState:UIControlStateNormal];
        [_changeModeButton addTarget:self action:@selector(changeModeAction) forControlEvents:UIControlEventTouchUpInside];
        _changeModeButton.selected = _mode == XPYAutoReadModeCover;
    }
    return _changeModeButton;
}
- (UIButton *)exitAutoReadButton {
    if (!_exitAutoReadButton) {
        _exitAutoReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exitAutoReadButton setTitle:@"退出自动阅读" forState:UIControlStateNormal];
        [_exitAutoReadButton setTitleColor:XPYColorFromHex(0x8F8F90) forState:UIControlStateNormal];
        _exitAutoReadButton.titleLabel.font = XPYFontRegular(14);
        _exitAutoReadButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [_exitAutoReadButton addTarget:self action:@selector(exitAutoReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitAutoReadButton;
}

@end
