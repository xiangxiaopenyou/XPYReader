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
    self.backgroundColor = XPYColorFromHex(0x232428);
    
    [self addSubview:self.speedLabel];
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).mas_offset(20);
        make.top.equalTo(self.mas_top).mas_offset(20);
        make.height.mas_offset(15);
    }];
    
    [self addSubview:self.changeModeButton];
    [self.changeModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).mas_offset(- 20);
        make.top.equalTo(self.mas_top).mas_offset(12.5);
        make.size.mas_equalTo(CGSizeMake(XPYScreenWidth / 2.0 - 30, 30));
    }];
    
    [self addSubview:self.minusSpeedButton];
    [self.minusSpeedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).mas_offset(20);
        make.top.equalTo(self.speedLabel.mas_bottom).mas_offset(20);
        make.size.mas_equalTo(CGSizeMake(XPYScreenWidth / 2.0 - 30, 30));
    }];
    
    [self addSubview:self.plusSpeedButton];
    [self.plusSpeedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).mas_offset(- 20);
        make.top.equalTo(self.speedLabel.mas_bottom).mas_offset(20);
        make.size.mas_equalTo(CGSizeMake(XPYScreenWidth / 2.0 - 30, 30));
    }];
    
    [self addSubview:self.exitAutoReadButton];
    [self.exitAutoReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.plusSpeedButton.mas_bottom).mas_offset(20);
        make.size.mas_offset(CGSizeMake(120, 30));
    }];
}

#pragma mark - Actions
- (void)minusSpeedAction {
    
}
- (void)plusSpeedAction {
    
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
        _speedLabel.font = FontRegular(14);
        _speedLabel.textColor = XPYColorFromHex(0x8F8F90);
        _speedLabel.textAlignment = NSTextAlignmentLeft;
        _speedLabel.text = [NSString stringWithFormat:@"自动翻页速度: %@", @(_speed)];
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
        _minusSpeedButton.titleLabel.font = FontRegular(14);
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
        _plusSpeedButton.titleLabel.font = FontRegular(14);
        [_plusSpeedButton addTarget:self action:@selector(plusSpeedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusSpeedButton;
}
- (UIButton *)changeModeButton {
    if (!_changeModeButton) {
        _changeModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeModeButton.titleLabel.font = FontRegular(14);
        _changeModeButton.layer.cornerRadius = 4;
        _changeModeButton.layer.borderWidth = 1;
        _changeModeButton.layer.borderColor = XPYColorFromHex(0x8F8F90).CGColor;
        [_changeModeButton setTitleColor:XPYColorFromHex(0x8F8F90) forState:UIControlStateNormal];
        [_changeModeButton setTitle:@"切换至滚屏模式" forState:UIControlStateSelected];
        [_changeModeButton setTitle:@"切换至覆盖模式" forState:UIControlStateNormal];
        [_changeModeButton addTarget:self action:@selector(changeModeAction) forControlEvents:UIControlEventTouchUpInside];
        _changeModeButton.selected = _mode == XPYAutoReadModeCover;
    }
    return _changeModeButton;
}
- (UIButton *)exitAutoReadButton {
    if (!_exitAutoReadButton) {
        _exitAutoReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exitAutoReadButton setTitle:@"退出自动翻页" forState:UIControlStateNormal];
        [_exitAutoReadButton setTitleColor:XPYColorFromHex(0x8F8F90) forState:UIControlStateNormal];
        _exitAutoReadButton.titleLabel.font = FontRegular(14);
        _exitAutoReadButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [_exitAutoReadButton setImage:[UIImage imageNamed:@"auto_read_exit"] forState:UIControlStateNormal];
        [_exitAutoReadButton addTarget:self action:@selector(exitAutoReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitAutoReadButton;
}

@end
