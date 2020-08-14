//
//  XPYReadMenu.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenu.h"

#import "XPYReadMenuTopBar.h"

static CGFloat const kXPYReadMenuAnimationDuration = 0.2;

@interface XPYReadMenu () <XPYReadMenuTopBarDelegate>

@property (nonatomic, strong) UIView *sourceView;

@property (nonatomic, strong) XPYReadMenuTopBar *topBar;

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
        
        [self configureUI];
        
        // 注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sourceView = XPYKeyWindow;
    }
    return self;
}

#pragma mark - Instance methods
- (void)show {
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sourceView.mas_top);
    }];
    [UIView animateWithDuration:kXPYReadMenuAnimationDuration animations:^{
        [self.sourceView layoutIfNeeded];
    }];
}
- (void)hidden {
    
}

#pragma mark - UI
- (void)configureUI {
    [self.sourceView addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sourceView);
        make.top.equalTo(self.sourceView.mas_top).mas_offset(- 44 - APP_STATUSBAR_HEIGHT);
        make.height.mas_offset(44 + APP_STATUSBAR_HEIGHT);
    }];
}

#pragma mark - Notifications
- (void)orientationChanged:(NSNotification *)notification {
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(44 + APP_STATUSBAR_HEIGHT);
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

@end
