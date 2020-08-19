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

#define kXPYBottomBarHeight XPYDeviceIsIphoneX ? 144 : 110
static CGFloat const kXPYReadMenuAnimationDuration = 0.2;

@interface XPYReadMenu () <XPYReadMenuTopBarDelegate>

@property (nonatomic, strong) UIView *sourceView;

@property (nonatomic, strong) XPYReadMenuTopBar *topBar;
@property (nonatomic, strong) XPYReadMenuBottomBar *bottomBar;

@property (nonatomic, assign) BOOL showing;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - UI
- (void)configureUI {
    [self.sourceView addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.top.equalTo(self.sourceView.mas_top).mas_offset(- 44 - APP_STATUSBAR_HEIGHT);
        make.height.mas_offset(44 + APP_STATUSBAR_HEIGHT);
    }];
    
    [self.sourceView addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYBottomBarHeight);
        make.height.mas_offset(kXPYBottomBarHeight);
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
        make.top.equalTo(self.sourceView.mas_top).mas_offset(- 44 - APP_STATUSBAR_HEIGHT);
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sourceView.mas_bottom).mas_offset(kXPYBottomBarHeight);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showing = NO;
    }];
}

#pragma mark - Notifications
- (void)orientationChanged:(NSNotification *)notification {
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(44 + APP_STATUSBAR_HEIGHT);
        if (_showing) {
            make.top.equalTo(self.sourceView.mas_top);
        } else {
            make.top.equalTo(self.sourceView.mas_top).mas_offset(- 44 - APP_STATUSBAR_HEIGHT);
        }
    }];
}

#pragma mark - XPYReadMenuTopBarDelegate
- (void)topBarDidClickBack {
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidClickBack)]) {
        [self.delegate readMenuDidClickBack];
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
    }
    return _bottomBar;
}

@end
