//
//  XPYReadMenuBackgroundBar.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/20.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenuBackgroundBar.h"

@interface XPYReadMenuBackgroundBar ()

/// 亮度滑动选择
@property (nonatomic, strong) UISlider *lightSlider;
/// 背景选择按钮父视图
@property (nonatomic, strong) UIView *buttonsView;
/// 当前选中颜色按钮
@property (nonatomic, strong) UIButton *selectedButton;
/// 当前背景色编号
@property (nonatomic, assign) NSInteger currentColorIndex;
/// 六种背景色色值
@property (nonatomic, copy) NSArray<UIColor *> *colors;
/// 保存颜色按钮，用于统一设置约束
@property (nonatomic, strong) NSMutableArray<UIButton *> *colorButtons;

@end

@implementation XPYReadMenuBackgroundBar

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame selectedColorIndex:(NSInteger)colorIndex {
    self = [super initWithFrame:frame];
    if (self) {
        self.colors = [@[XPYReadBackgroundColor1, XPYReadBackgroundColor2, XPYReadBackgroundColor3, XPYReadBackgroundColor4, XPYReadBackgroundColor5, XPYReadBackgroundColor6] copy];
        _currentColorIndex = colorIndex;
        [self configureUI];
    }
    return self;
}

#pragma mark - UI
- (void)configureUI {
    
    self.backgroundColor = XPYColorFromHex(0x222222);
    
    UILabel *lightLabel = [[UILabel alloc] init];
    lightLabel.text = @"亮度";
    lightLabel.font = [UIFont systemFontOfSize:14];
    lightLabel.textColor = [UIColor whiteColor];
    [self addSubview:lightLabel];
    [lightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).mas_offset(10);
        } else {
            make.leading.equalTo(self.mas_leading).mas_offset(10);
        }
        make.top.equalTo(self.mas_top).mas_offset(15);
        make.height.mas_equalTo(25);
    }];
    
    [self addSubview:self.lightSlider];
    [self.lightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).mas_offset(- 10);
        } else {
            make.trailing.equalTo(self.mas_trailing).mas_offset(- 10);
        }
        make.leading.equalTo(lightLabel.mas_trailing).mas_offset(10);
        make.top.equalTo(self.mas_top).mas_offset(15);
        make.height.mas_equalTo(25);
    }];
    
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.backgroundColor = XPYColorFromHex(0x222222);
    [self addSubview:self.buttonsView];
    [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.lightSlider.mas_bottom).mas_offset(10);
        make.height.mas_offset(30);
    }];
    
    [self.colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = obj;
        button.tag = idx + 1000;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        if (idx == _currentColorIndex) {
            button.layer.borderWidth = 2;
            button.layer.borderColor = XPYColorFromHex(0xf46663).CGColor;
            self.selectedButton = button;
        }
        [button addTarget:self action:@selector(selectColorAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.colorButtons addObject:button];
        [self.buttonsView addSubview:button];
    }];
    
    [self.colorButtons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:30 leadSpacing:20 tailSpacing:20];
    [self.colorButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(30, 30));
        make.centerY.equalTo(self.buttonsView);
    }];
}

#pragma mark - Instance methods
- (void)updateButtonsConstraints {
    // 根据手机屏幕方向调整按钮位置
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat spacing = orientation == UIInterfaceOrientationPortrait ? 0 : (XPYDeviceIsIphoneX ? 44 : 0);
    [self.buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).mas_offset(spacing);
        make.trailing.equalTo(self.mas_trailing).mas_offset(- spacing);
        make.top.equalTo(self.lightSlider.mas_bottom).mas_offset(10);
        make.height.mas_offset(30);
    }];
}
- (void)updateSelectedColorWithColorIndex:(NSInteger)colorIndex {
    if (colorIndex >= self.colorButtons.count) {
        return;
    }
    if (self.selectedButton.tag - 1000 == colorIndex) {
        return;
    }
    
    UIButton *tempButton = self.colorButtons[colorIndex];

    self.selectedButton.layer.borderWidth = 1;
    self.selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    tempButton.layer.borderWidth = 2;
    tempButton.layer.borderColor = XPYColorFromHex(0xf46663).CGColor;
    
    self.selectedButton = tempButton;
}

#pragma mark - Event response
- (void)lightChanged:(UISlider *)slider {
    [UIScreen mainScreen].brightness = slider.value;
}
- (void)selectColorAction:(UIButton *)button {
    if (button.tag == self.selectedButton.tag) {
        return;
    }
    self.selectedButton.layer.borderWidth = 1;
    self.selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    button.layer.borderWidth = 2;
    button.layer.borderColor = XPYColorFromHex(0xf46663).CGColor;
    
    self.selectedButton = button;
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(backgroundBarDidSelectColorIndex:)]) {
        [self.delegate backgroundBarDidSelectColorIndex:button.tag - 1000];
    }
}

#pragma mark - Getters
- (UISlider *)lightSlider {
    if (!_lightSlider) {
        _lightSlider = [[UISlider alloc] init];
        _lightSlider.minimumValue = 0.0;;
        _lightSlider.maximumValue = 1.0;
        _lightSlider.minimumTrackTintColor = [UIColor yellowColor];
        _lightSlider.maximumTrackTintColor = [UIColor grayColor];
        [_lightSlider addTarget:self action:@selector(lightChanged:) forControlEvents:UIControlEventValueChanged];
        _lightSlider.value = [UIScreen mainScreen].brightness;
    }
    return _lightSlider;
}
- (NSMutableArray *)colorButtons {
    if (!_colorButtons) {
        _colorButtons = [[NSMutableArray alloc] init];
    }
    return _colorButtons;
}

@end
