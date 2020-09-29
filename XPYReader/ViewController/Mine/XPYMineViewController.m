//
//  XPYMineViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYMineViewController.h"
#import "XPYLoginViewController.h"
#import "XPYNavigationController.h"
#import "XPYUserManager.h"

@interface XPYMineViewController ()

@property (nonatomic, strong) UIImageView *avartarImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;

@end

@implementation XPYMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.avartarImageView];
    [self.avartarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(40);
        make.size.mas_offset(CGSizeMake(70, 70));
    }];
    
    [self.view addSubview:self.nicknameLabel];
    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.avartarImageView.mas_bottom).mas_offset(15);
    }];
    
    [self.view addSubview:self.userIdLabel];
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.nicknameLabel.mas_bottom).mas_offset(10);
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubviews];
}

#pragma mark - Private methods
- (void)updateSubviews {
    if ([XPYUserManager sharedInstance].isLogin) {
        self.userIdLabel.hidden = NO;
        self.userIdLabel.text = [XPYUserManager sharedInstance].currentUser.userId;
        self.nicknameLabel.text = [XPYUserManager sharedInstance].currentUser.nickname;
        [self.avartarImageView sd_setImageWithURL:[NSURL URLWithString:[XPYUserManager sharedInstance].currentUser.avatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else {
        self.userIdLabel.hidden = YES;
        self.nicknameLabel.text = @"点击头像登录";
        self.avartarImageView.image = [UIImage imageNamed:@"default_avatar"];
    }
}

#pragma mark - Actions
- (void)avatarTap:(UITapGestureRecognizer *)tap {
    if ([XPYUserManager sharedInstance].isLogin) {
        
    } else {
        XPYLoginViewController *loginController = [[XPYLoginViewController alloc] init];
        [self.navigationController pushViewController:loginController animated:YES];
    }
}

#pragma mark - Getters
- (UIImageView *)avartarImageView {
    if (!_avartarImageView) {
        _avartarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar"]];
        _avartarImageView.userInteractionEnabled = YES;
        [_avartarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap:)]];
    }
    return _avartarImageView;
}
- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nicknameLabel.text = @"点击头像登录";
        _nicknameLabel.textColor = [UIColor blackColor];
    }
    return _nicknameLabel;
}
- (UILabel *)userIdLabel {
    if (!_userIdLabel) {
        _userIdLabel = [[UILabel alloc] init];
        _userIdLabel.font = [UIFont systemFontOfSize:14];
        _userIdLabel.textColor = [UIColor grayColor];
    }
    return _userIdLabel;
}

@end
