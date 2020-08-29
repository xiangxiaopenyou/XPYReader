//
//  XPYReadMenu.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenu.h"

#import "XPYReadMenuTopBar.h"
#import "XPYReadMenuBottomBar.h"
#import "XPYReadMenuBackgroundBar.h"
#import "XPYReadMenuPageTypeBar.h"
#import "XPYReadMenuSettingBar.h"
#import "XPYReadMenuAutoReadSettingBar.h"

#define kXPYTopBarHeight [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? (44 + XPYStatusBarHeight) : 64
#define kXPYBottomBarHeight XPYDeviceIsIphoneX ? 144 : 110
#define kXPYSettingBarHeight [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? (XPYDeviceIsIphoneX ? 190 : 168) : (XPYDeviceIsIphoneX ? 140 : 120)
#define kXPYAutoReadSettingBarHeight XPYDeviceIsIphoneX ? 174 : 140

static CGFloat const kXPYBackgroundBarHeight = 100.f;
static CGFloat const kXPYPageTypeBarHeight = 79.f;
static CGFloat const kXPYReadMenuAnimationDuration = 0.2;

@interface XPYReadMenu () <XPYReadMenuTopBarDelegate, XPYReadMenuBottomBarDelegate, XPYReadMenuBackgroundBarDelegate, XPYReadMenuPageTypeBarDelegate, XPYReadMenuSettingBarDelegate, XPYReadMenuAutoReadSettingBarDelegate>

@property (nonatomic, strong) UIView *sourceView;

/// 顶部栏
@property (nonatomic, strong) XPYReadMenuTopBar *topBar;
/// 底部栏
@property (nonatomic, strong) XPYReadMenuBottomBar *bottomBar;
/// 背景选择栏
@property (nonatomic, strong) XPYReadMenuBackgroundBar *backgroundBar;
/// 翻页模式选择栏
@property (nonatomic, strong) XPYReadMenuPageTypeBar *pageTypeBar;
/// 设置栏
@property (nonatomic, strong) XPYReadMenuSettingBar *settingBar;
/// 自动阅读设置栏
@property (nonatomic, strong) XPYReadMenuAutoReadSettingBar *autoReadSettingBar;

/// 是否显示默认菜单（topBar和bottomBar）
@property (nonatomic, assign) BOOL showing;
/// 是否显示翻页模式选择栏
@property (nonatomic, assign) BOOL isShowingPageType;
/// 是否显示设置栏
@property (nonatomic, assign) BOOL isShowingSettingBar;
/// 是否显示自动阅读设置栏
@property (nonatomic, assign) BOOL showingAutoReadSetting;

@end

@implementation XPYReadMenu

#pragma mark - Initializer
- (instancetype)initWithView:(UIView *)sourceView {
    self = [super init];
    if (self) {
        if (!sourceView) {
            self.sourceView = XPYKeyWindow;
        }
        self.sourceView = sourceView;
        
        [self initialize];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sourceView = XPYKeyWindow;
        [self initialize];
    }
    return self;
}
- (void)initialize {
    [self configureUI];
    
    // 注册屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

#pragma mark - UI
- (void)configureUI {
    [self.sourceView addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.top.equalTo(self.sourceView.mas_top).mas_offset(- (kXPYTopBarHeight));
        make.height.mas_offset(kXPYTopBarHeight);
    }];
    
    [self.sourceView addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYBottomBarHeight);
        make.height.mas_offset(kXPYBottomBarHeight);
    }];
    
    [self.sourceView addSubview:self.backgroundBar];
    [self.backgroundBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.bottom.equalTo(self.bottomBar.mas_top).mas_offset(50);
        make.height.mas_offset(kXPYBackgroundBarHeight);
    }];
    
    [self.sourceView addSubview:self.pageTypeBar];
    [self.pageTypeBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.bottom.equalTo(self.bottomBar.mas_top).mas_offset(50);
        make.height.mas_offset(kXPYPageTypeBarHeight);
    }];
    
    [self.sourceView addSubview:self.settingBar];
    [self.settingBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.height.mas_offset(kXPYSettingBarHeight);
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYSettingBarHeight);
    }];
    
    [self.sourceView addSubview:self.autoReadSettingBar];
    [self.autoReadSettingBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.height.mas_offset(kXPYAutoReadSettingBarHeight);
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYAutoReadSettingBarHeight);
    }];
}

#pragma mark - Instance methods
- (void)show {
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sourceView.mas_top);
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showing = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuHideStatusDidChange:)]) {
            [self.delegate readMenuHideStatusDidChange:YES];
        }
    }];
}
- (void)hiddenWithComplete:(void (^)(void))complete {
    if (!self.pageTypeBar.hidden) {
        // 如果翻页模式选择栏已显示，则需要手动隐藏
        self.pageTypeBar.hidden = YES;
    }
    if (!self.backgroundBar.hidden) {
        // 如果背景选择栏已显示，则需要手动隐藏
        self.backgroundBar.hidden = YES;
    }
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sourceView.mas_top).mas_offset(- (kXPYTopBarHeight));
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYBottomBarHeight);
    }];
    [self.settingBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYSettingBarHeight);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showing = NO;
        self.isShowingSettingBar = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuHideStatusDidChange:)]) {
            [self.delegate readMenuHideStatusDidChange:YES];
        }
        !complete ?: complete();
    }];
}

- (void)updateSelectedBackgroundWithColorIndex:(NSInteger)colorIndex {
    [self.backgroundBar updateSelectedColorWithColorIndex:colorIndex];
}

- (void)showAutoReadSetting {
    [self.autoReadSettingBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showingAutoReadSetting = YES;
    }];
}

- (void)hideAutoReadSetting {
    [self.autoReadSettingBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYAutoReadSettingBarHeight);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showingAutoReadSetting = NO;
    }];
}

#pragma mark - Notifications
- (void)orientationChanged:(NSNotification *)notification {
    // topBar高度更新（因为iphoneX屏幕横屏返回statusbar高度为0）
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(kXPYTopBarHeight);
        if (_showing) {
            make.top.equalTo(self.sourceView.mas_top);
        } else {
            make.top.equalTo(self.sourceView.mas_top).mas_offset(- (kXPYTopBarHeight));
        }
    }];
    // settingBar高度更新（因为横竖屏高度不一样）
    [self.settingBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(kXPYSettingBarHeight);
        if (_isShowingSettingBar) {
            make.bottom.equalTo(self.sourceView.mas_bottom);
        } else {
            make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYSettingBarHeight);
        }
    }];
    [self.settingBar updateViewsConstraints];
    [self.backgroundBar updateButtonsConstraints];
    [self.pageTypeBar updateButtonsConstraints];
}

#pragma mark - XPYReadMenuTopBarDelegate
- (void)topBarDidClickBack {
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidExitReader)]) {
        [self.delegate readMenuDidExitReader];
    }
}

#pragma mark - XPYReadMenuBottomBarDelegate
- (void)bottomBarDidClickBackground {
    if (!self.pageTypeBar.hidden) {
        // 如果翻页模式选择栏已显示，则需要手动隐藏
        self.pageTypeBar.hidden = YES;
    }
    // 背景选择栏显示和隐藏
    self.backgroundBar.hidden = !self.backgroundBar.hidden;
}
- (void)bottomBarDidClickPageType {
    if (!self.backgroundBar.hidden) {
        // 如果背景选择栏已显示，则需要手动隐藏
        self.backgroundBar.hidden = YES;
    }
    // 控制翻页模式选择栏显示和隐藏
    self.pageTypeBar.hidden = !self.pageTypeBar.hidden;
}
- (void)bottomBarDidClickSetting {
    if (!self.backgroundBar.hidden) {
        // 如果背景选择栏已显示，则需要手动隐藏
        self.backgroundBar.hidden = YES;
    }
    if (!self.pageTypeBar.hidden) {
        // 如果翻页模式选择栏已显示，则需要手动隐藏
        self.pageTypeBar.hidden = YES;
    }
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYBottomBarHeight);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 隐藏底部栏动画完成之后显示设置栏
        [self.settingBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.sourceView.mas_bottom);
        }];
        [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
            [self.sourceView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isShowingSettingBar = YES;
        }];
    }];
    
}

#pragma mark - XPYReadMenuBackgroundBarDelegate
- (void)backgroundBarDidSelectColorIndex:(NSInteger)colorIndex {
    [[XPYReadConfigManager sharedInstance] updateColorIndex:colorIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidChangeBackground)]) {
        [self.delegate readMenuDidChangeBackground];
    }
}

#pragma mark - XPYReadMenuPageTypeBarDelegate
- (void)pageTypeBarDidSelectType {
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidChangePageType)]) {
        [self.delegate readMenuDidChangePageType];
    }
}

#pragma mark - XPYReadMenuSettingBarDelegate
- (void)settingBarClickAutoRead {
    // 开启自动阅读
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidOpenAutoRead)]) {
        [self.delegate readMenuDidOpenAutoRead];
    }
}

#pragma mark - XPYReadMenuAutoReadSettingBarDelegate
- (void)autoReadSettingBarDidClickExit {
    // 关闭自动阅读
    [self hideAutoReadSetting];
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidCloseAutoRead)]) {
        [self.delegate readMenuDidCloseAutoRead];
    }
}
- (void)autoReadSettingBarDidChangeMode:(XPYAutoReadMode)mode {
    [self hideAutoReadSetting];
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidChangeAutoReadMode:)]) {
        [self.delegate readMenuDidChangeAutoReadMode:mode];
    }
}

#pragma mark - Getters
- (XPYReadMenuTopBar *)topBar {
    if (!_topBar) {
        _topBar = [[XPYReadMenuTopBar alloc] initWithFrame:CGRectZero];
        _topBar.delegate = self;
    }
    return _topBar;
}
- (XPYReadMenuBottomBar *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[XPYReadMenuBottomBar alloc] initWithFrame:CGRectZero];
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}
- (XPYReadMenuBackgroundBar *)backgroundBar {
    if (!_backgroundBar) {
        _backgroundBar = [[XPYReadMenuBackgroundBar alloc] initWithFrame:CGRectZero selectedColorIndex:[XPYReadConfigManager sharedInstance].currentColorIndex];
        _backgroundBar.hidden = YES;
        _backgroundBar.delegate = self;
    }
    return _backgroundBar;
}
- (XPYReadMenuPageTypeBar *)pageTypeBar {
    if (!_pageTypeBar) {
        _pageTypeBar = [[XPYReadMenuPageTypeBar alloc] initWithFrame:CGRectZero];
        _pageTypeBar.hidden = YES;
        _pageTypeBar.delegate = self;
    }
    return _pageTypeBar;
}
- (XPYReadMenuSettingBar *)settingBar {
    if (!_settingBar) {
        _settingBar = [[XPYReadMenuSettingBar alloc] initWithFrame:CGRectZero];
        _settingBar.delegate = self;
    }
    return _settingBar;
}
- (XPYReadMenuAutoReadSettingBar *)autoReadSettingBar {
    if (!_autoReadSettingBar) {
        _autoReadSettingBar = [[XPYReadMenuAutoReadSettingBar alloc] initWithFrame:CGRectZero];
        _autoReadSettingBar.delegate = self;
    }
    return _autoReadSettingBar;
}

@end
