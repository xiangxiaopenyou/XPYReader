//
//  XPYReadMenuTopBar.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenuTopBar.h"

@interface XPYReadMenuTopBar ()

/// 返回按钮
@property (nonatomic, strong) UIButton *backButton;
/// 分享按钮
@property (nonatomic, strong) UIButton *shareButton;
/// 听书按钮
@property (nonatomic, strong) UIButton *listenButton;
/// 书籍详情按钮
@property (nonatomic, strong) UIButton *bookDetailsButton;
/// 纠错按钮
@property (nonatomic, strong) UIButton *errorCorrectionButton;

@end

@implementation XPYReadMenuTopBar

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
    
    [self addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(self);
        make.size.mas_offset(CGSizeMake(50, 44));
    }];
}

#pragma mark - Event response
- (void)backAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarDidClickBack)]) {
        [self.delegate topBarDidClickBack];
    }
}

#pragma mark - Getters
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"light_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end
