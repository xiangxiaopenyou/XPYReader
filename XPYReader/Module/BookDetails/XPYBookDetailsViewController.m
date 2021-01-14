//
//  XPYBookDetailsViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookDetailsViewController.h"
#import "XPYReaderManagerController.h"

#import "XPYNetworkService+Book.h"
#import "XPYBookModel.h"
#import "XPYReadRecordManager.h"
#import "XPYReadHelper.h"
#import "XPYUserManager.h"

@interface XPYBookDetailsViewController ()

@property (nonatomic, strong) UIImageView *bookCoverImageView;
@property (nonatomic, strong) UILabel *bookNameLabel;
@property (nonatomic, strong) UILabel *bookIntroductionLabel;
/// 开始阅读按钮
@property (nonatomic, strong) UIButton *readButton;
/// 加入书架/移出书架按钮
@property (nonatomic, strong) UIButton *stackOperateButton;

@property (nonatomic, strong) XPYBookModel *bookModel;

@end

@implementation XPYBookDetailsViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bookDetailsRequest];
}

#pragma mark - UI
- (void)configureUI {
    [self.view addSubview:self.bookCoverImageView];
    [self.view addSubview:self.bookNameLabel];
    [self.view addSubview:self.bookIntroductionLabel];
    [self.view addSubview:self.readButton];
    [self.view addSubview:self.stackOperateButton];
    
    [self.bookCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(20);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(20);
        } else {
            make.top.equalTo(self.view.mas_top).mas_offset(20);
        }
        make.size.mas_offset(CGSizeMake(120, 160));
    }];
    
    [self.bookNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bookCoverImageView.mas_trailing).mas_offset(15);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(- 15);
        make.centerY.equalTo(self.bookCoverImageView.mas_centerY);
    }];
    
    [self.bookIntroductionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(20);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(- 20);
        make.top.equalTo(self.bookCoverImageView.mas_bottom).mas_offset(15);
    }];
    
    [self.readButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.height.mas_offset(40);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.5);
    }];
    
    [self.stackOperateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.leading.equalTo(self.readButton.mas_trailing);
        make.height.mas_offset(40);
    }];
    
}

#pragma mark - Network
- (void)bookDetailsRequest {
    [[XPYNetworkService sharedService] bookDetailsRequestWithBookId:self.bookId success:^(id result) {
        if ([XPYReadRecordManager recordWithBookId:self.bookId]) {
            // 存在阅读记录
            self.bookModel = [XPYReadRecordManager recordWithBookId:self.bookId];
        } else {
            // 不存在阅读记录时 isInStack为NO
            self.bookModel = (XPYBookModel *)result;
            self.bookModel.isInStack = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureUI];
        });
    } failure:^(NSError *error) {
        [MBProgressHUD xpy_showTips:@"网络错误"];
    }];
}

#pragma mark - Event response
/// 开始阅读
- (void)readAction {
    [XPYReadHelper readWithBook:self.bookModel];
}

/// 加入/移出书架
- (void)stackOperateAction {
    [MBProgressHUD xpy_showHUD];
    if ([XPYUserManager sharedInstance].isLogin) {
        // 登录情况下加入/移出书架需要上传服务端
    } else {
        // 未登录情况下加入/移出书架只在本地数据库中操作
        if (self.bookModel.isInStack) {
            // 移出书架
            [XPYReadHelper removeFormBookStackWithBook:self.bookModel complete:^{
                self.bookModel.isInStack = NO;
                [self.stackOperateButton setTitle:@"加入书架" forState:UIControlStateNormal];
                [MBProgressHUD xpy_showTips:@"已移出书架"];
                [[NSNotificationCenter defaultCenter] postNotificationName:XPYBookStackDidChangeNotification object:nil];
            }];
        } else {
            // 加入书架
            [XPYReadHelper addToBookStackWithBook:self.bookModel complete:^{
                self.bookModel.isInStack = YES;
                [self.stackOperateButton setTitle:@"移出书架" forState:UIControlStateNormal];
                [MBProgressHUD xpy_showTips:@"已加入书架"];
                [[NSNotificationCenter defaultCenter] postNotificationName:XPYBookStackDidChangeNotification object:nil];
            }];
        }
    }
}

#pragma mark - Getters
- (UIImageView *)bookCoverImageView {
    if (!_bookCoverImageView) {
        _bookCoverImageView = [[UIImageView alloc] init];
        [_bookCoverImageView sd_setImageWithURL:[NSURL URLWithString:self.bookModel.bookCoverURL]];
    }
    return _bookCoverImageView;
}
- (UILabel *)bookNameLabel {
    if (!_bookNameLabel) {
        _bookNameLabel = [[UILabel alloc] init];
        _bookNameLabel.textColor = [UIColor blackColor];
        _bookNameLabel.font = [UIFont boldSystemFontOfSize:18];
        _bookNameLabel.numberOfLines = 2;
        _bookNameLabel.text = self.bookModel.bookName;
    }
    return _bookNameLabel;
}
- (UILabel *)bookIntroductionLabel {
    if (!_bookIntroductionLabel) {
        _bookIntroductionLabel = [[UILabel alloc] init];
        _bookIntroductionLabel.textColor = [UIColor grayColor];
        _bookIntroductionLabel.font = [UIFont systemFontOfSize:14];\
        _bookIntroductionLabel.numberOfLines = 0;
        _bookIntroductionLabel.text = self.bookModel.bookIntroduction;
    }
    return _bookIntroductionLabel;
}
- (UIButton *)readButton {
    if (!_readButton) {
        _readButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_readButton setTitle:@"开始阅读" forState:UIControlStateNormal];
        [_readButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_readButton addTarget:self action:@selector(readAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _readButton;
}
- (UIButton *)stackOperateButton {
    if (!_stackOperateButton) {
        _stackOperateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stackOperateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_stackOperateButton setTitle:self.bookModel.isInStack ? @"移出书架" : @"加入书架" forState:UIControlStateNormal];
        [_stackOperateButton addTarget:self action:@selector(stackOperateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stackOperateButton;
}

@end
