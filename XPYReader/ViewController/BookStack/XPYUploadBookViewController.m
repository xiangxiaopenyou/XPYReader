//
//  XPYUploadBookViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/12/19.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYUploadBookViewController.h"

#import <GCDWebUploader.h>

@interface XPYUploadBookViewController ()<GCDWebUploaderDelegate>

@property (nonatomic, strong) GCDWebUploader *uploader;

@property (nonatomic, strong) UILabel *ipLabel;

@end

@implementation XPYUploadBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WiFi传书";
    
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

@end
