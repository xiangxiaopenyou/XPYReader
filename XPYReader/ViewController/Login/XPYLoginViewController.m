//
//  XPYLoginViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYLoginViewController.h"

#import "XPYNetworkService+User.h"
#import "XPYUserManager.h"
#import "XPYReadHelper.h"


@interface XPYLoginViewController ()

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation XPYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    
    [self.usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(300, 50));
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(50);
        } else {
            make.top.equalTo(self.view.mas_top).mas_offset(50);
        }
        make.centerX.equalTo(self.view);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(300, 50));
        make.top.equalTo(self.usernameTextField.mas_bottom).mas_offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(250, 40));
        make.top.equalTo(self.passwordTextField.mas_bottom).mas_offset(30);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - Actions
- (void)loginAction {
    [MBProgressHUD xpy_showActivityHUDWithTips:@"正在登录..."];
    [[XPYNetworkService sharedService] loginWithPhone:self.usernameTextField.text password:XPYMD5StringWithString(self.passwordTextField.text) success:^(id result) {
        [MBProgressHUD xpy_hideHUD];
        // 保存用户信息
        [[XPYUserManager sharedInstance] saveUser:(XPYUserModel *)result];
        // 同步书架数据
        [XPYReadHelper synchronizeStackBooksAndReadRecordsComplete:^{
            [self.navigationController popViewControllerAnimated:YES];
            // 发送登录状态变化通知
            [[NSNotificationCenter defaultCenter] postNotificationName:XPYLoginStatusDidChangeNotification object:nil];
        }];
    } failure:^(NSError *error) {
        [MBProgressHUD xpy_showTips:@"登录失败"];
    }];
}

#pragma mark - Getters
- (UITextField *)usernameTextField {
    if (!_usernameTextField) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.backgroundColor = [UIColor grayColor];
        _usernameTextField.placeholder = @"手机号";
    }
    return _usernameTextField;
}
- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.placeholder = @"密码";
        _passwordTextField.backgroundColor = [UIColor grayColor];
        _passwordTextField.secureTextEntry = YES;
    }
    return _passwordTextField;
}
- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setBackgroundColor:[UIColor redColor]];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;;
}

@end
