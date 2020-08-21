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
#import "XPYReadMenuPageTypeBar.h"

#define kXPYTopBarHeight [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? (44 + APP_STATUSBAR_HEIGHT) : 64
#define kXPYBottomBarHeight XPYDeviceIsIphoneX ? 144 : 110

static CGFloat const kXPYPageTypeBarHeight = 79.f;
static CGFloat const kXPYReadMenuAnimationDuration = 0.2;

@interface XPYReadMenu () <XPYReadMenuTopBarDelegate, XPYReadMenuBottomBarDelegate, XPYReadMenuPageTypeBarDelegate>

@property (nonatomic, strong) UIView *sourceView;

/// 顶部栏
@property (nonatomic, strong) XPYReadMenuTopBar *topBar;
/// 底部栏
@property (nonatomic, strong) XPYReadMenuBottomBar *bottomBar;
/// 翻页模式选择栏
@property (nonatomic, strong) XPYReadMenuPageTypeBar *pageTypeBar;

@property (nonatomic, assign) BOOL showing;
/// 是否显示翻页模式选择栏
@property (nonatomic, assign) BOOL isShowingPageType;

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
    
    [self.sourceView addSubview:self.pageTypeBar];
    [self.pageTypeBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(- ((kXPYBottomBarHeight) - 50));
        make.height.mas_offset(kXPYPageTypeBarHeight);
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
    }];
}
- (void)hidden {
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sourceView.mas_top).mas_offset(- (kXPYTopBarHeight));
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYBottomBarHeight);
    }];
    if (!self.pageTypeBar.hidden) {
        // 如果翻页模式选择栏已显示，则需要手动隐藏
        self.pageTypeBar.hidden = YES;
    }
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showing = NO;
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
}

#pragma mark - XPYReadMenuTopBarDelegate
- (void)topBarDidClickBack {
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidClickBack)]) {
        [self.delegate readMenuDidClickBack];
    }
}

#pragma mark - XPYReadMenuBottomBarDelegate
- (void)bottomBarDidClickBackground {
    
}
- (void)bottomBarDidClickPageType {
    // 控制翻页模式选择栏显示和隐藏
    self.pageTypeBar.hidden = !self.pageTypeBar.hidden;
}

#pragma mark - XPYReadMenuPageTypeBarDelegate
- (void)pageTypeBarDidSelectType:(XPYReadPageType)type {
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidChangePageType:)]) {
        [self.delegate readMenuDidChangePageType:type];
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
- (XPYReadMenuPageTypeBar *)pageTypeBar {
    if (!_pageTypeBar) {
        _pageTypeBar = [[XPYReadMenuPageTypeBar alloc] initWithFrame:CGRectZero];
        _pageTypeBar.hidden = YES;
        _pageTypeBar.delegate = self;
    }
    return _pageTypeBar;
}

@end
