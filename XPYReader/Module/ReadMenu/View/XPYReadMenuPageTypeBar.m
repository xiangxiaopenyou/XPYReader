//
//  XPYReadMenuPageTypeBar.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/20.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenuPageTypeBar.h"

@interface XPYReadMenuPageTypeBar ()

// 翻页模式选择按钮父视图
@property (nonatomic, strong) UIView *buttonsView;
@property (nonatomic, strong) UIButton *selectedTypeButton;

@end

@implementation XPYReadMenuPageTypeBar

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
    
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.backgroundColor = XPYColorFromHex(0x222222);
    [self addSubview:self.buttonsView];
    [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.centerY.equalTo(self);
        make.height.mas_offset(33);
    }];
    
    NSArray <NSString *> *pageTypes = @[@"仿真翻页", @"上下翻页", @"平移翻页", @"无效果"];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    [pageTypes enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = XPYFontRegular(13);
        [button setTitle:obj forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
        button.tag = 1000 + idx;
        [button addTarget:self action:@selector(pageTypeSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        if (idx == [XPYReadConfigManager sharedInstance].pageType) {
            button.selected = YES;
            self.selectedTypeButton = button;
        }
        [self.buttonsView addSubview:button];
        [buttons addObject:button];
    }];
    [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:64 leadSpacing:20 tailSpacing:20];
    [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(64, 33));
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
        make.centerY.equalTo(self);
        make.height.mas_offset(33);
    }];
}

#pragma mark - Event response
- (void)pageTypeSelectAction:(UIButton *)sender {
    if (sender.isSelected) {
        return;
    }
    self.selectedTypeButton.selected = NO;
    sender.selected = YES;
    self.selectedTypeButton = sender;
    
    // 更新阅读页翻页模式配置
    [[XPYReadConfigManager sharedInstance] updatePageType:self.selectedTypeButton.tag - 1000];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageTypeBarDidSelectType)]) {
        [self.delegate pageTypeBarDidSelectType];
    }
}

@end
