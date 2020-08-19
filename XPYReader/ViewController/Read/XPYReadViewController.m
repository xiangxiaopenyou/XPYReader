//
//  XPYReadViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadViewController.h"


@interface XPYReadViewController ()

@property (nonatomic, strong) XPYReadView *readView;

@property (nonatomic, strong) XPYChapterModel *chapterModel;
@property (nonatomic, copy) NSAttributedString *chapterContent;
@property (nonatomic, copy) NSArray *pageRanges;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy) NSAttributedString *pageContent;

@end

@implementation XPYReadViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.readView];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(- XPYReadViewRightSpacing);
        make.top.equalTo(self.view.mas_top).mas_offset(XPYReadViewTopSpacing);
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(- XPYReadViewBottomSpacing);
    }];
}

#pragma mark - Instance methods
- (void)setupChapter:(XPYChapterModel *)chapter chapterContent:(NSAttributedString *)chapterContent pageRanges:(NSArray *)pageRanges page:(NSInteger)page pageContent:(NSAttributedString *)pageContent {
    self.chapterModel = chapter;
    self.chapterContent = chapterContent;
    self.pageRanges = [pageRanges copy];
    _page = page;
    self.pageContent = pageContent;
    [self.readView setupContent:pageContent];
    [self.view setNeedsLayout];
}

#pragma mark - Getters
- (XPYReadView *)readView {
    if (!_readView) {
        _readView = [[XPYReadView alloc] initWithFrame:CGRectZero];
    }
    return _readView;
}

@end
