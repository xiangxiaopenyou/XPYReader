//
//  XPYUploadBookViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/12/19.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYUploadBookViewController.h"

#import "XPYReadParser.h"
#import "XPYChapterDataManager.h"
#import "XPYReadHelper.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

#import <GCDWebUploader.h>

@interface XPYUploadBookViewController ()<GCDWebUploaderDelegate>

@property (nonatomic, strong) GCDWebUploader *uploader;

@property (nonatomic, strong) UILabel *ipLabel;

@end

@implementation XPYUploadBookViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WiFi传书";
    
    [self.view addSubview:self.ipLabel];
    [self.ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.leading.equalTo(self.view.mas_leading).mas_offset(30);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(-30);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.uploader start]) {
        self.ipLabel.text = [NSString stringWithFormat:@"保证电脑和手机在同一网络下\n\n在电脑浏览器中访问以下地址：\n\n%@", self.uploader.serverURL.absoluteString];
    } else {
        self.ipLabel.text = @"启动服务失败，请检查网络";
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.uploader) {
        [self.uploader stop];
        self.uploader.delegate = nil;
        _uploader = nil;
    }
}

- (void)dealloc {
    
}

#pragma mark - GCDWebUploaderDelegate
- (void)webUploader:(GCDWebUploader *)uploader didUploadFileAtPath:(NSString *)path {
    // 上传完成解析书籍
    if (path) {
        [XPYReadParser parseLocalBookWithFilePath:path success:^(NSArray<XPYChapterModel *> * _Nonnull chapters) {
            // 创建书籍模型
            XPYBookModel *bookModel = [[XPYBookModel alloc] init];
            bookModel.bookType = XPYBookTypeLocal;
            bookModel.bookName = path.lastPathComponent;
            // 本地书随机生成ID
            bookModel.bookId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970] * 1000)];
            bookModel.chapterCount = chapters.count;
            for (XPYChapterModel *chapter in chapters) {
                chapter.bookId = bookModel.bookId;
            }
            [XPYReadHelper addToBookStackWithBook:bookModel complete:^{
                [XPYChapterDataManager insertChaptersWithModels:chapters];
                [MBProgressHUD xpy_showSuccessTips:@"书籍已经成功加入书架"];
            }];
        } failure:^(NSError *error) {
            [MBProgressHUD xpy_showErrorTips:error.userInfo[NSUnderlyingErrorKey]];
        }];
    }
}

#pragma mark - Getters
- (GCDWebUploader *)uploader {
    if (!_uploader) {
        _uploader = [[GCDWebUploader alloc] initWithUploadDirectory:XPYFilePath(@"books")];
        _uploader.allowedFileExtensions = @[@"txt"];
        _uploader.delegate = self;
    }
    return _uploader;
}
- (UILabel *)ipLabel {
    if (!_ipLabel) {
        _ipLabel = [[UILabel alloc] init];
        _ipLabel.textAlignment = NSTextAlignmentCenter;
        _ipLabel.numberOfLines = 0;
    }
    return _ipLabel;
}

@end
