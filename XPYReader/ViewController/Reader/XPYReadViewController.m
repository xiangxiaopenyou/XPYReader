//
//  XPYReadViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadViewController.h"

#import "XPYReadView.h"

#import "XPYChapterPageModel.h"
#import "XPYChapterModel.h"
#import "XPYParagraphModel.h"

#import "XPYReadRecordManager.h"
#import "XPYReadParser.h"


@interface XPYReadViewController ()

@property (nonatomic, strong) XPYReadView *readView;
/// 章节名
@property (nonatomic, strong) UILabel *chapterNameLabel;
/// 当前页码
@property (nonatomic, strong) UILabel *currentPageLabel;

@property (nonatomic, strong) XPYChapterModel *chapterModel;
@property (nonatomic, strong) XPYChapterPageModel *pageModel;

@property (nonatomic, assign) BOOL backView;

@end

@implementation XPYReadViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    [self refreshInformationViews];
    
    if ([XPYReadConfigManager sharedInstance].pageType == XPYReadPageTypeTranslation || [XPYReadConfigManager sharedInstance].pageType == XPYReadPageTypeNone) {
        // 左右平移和无动画翻页模式添加点击边缘翻页事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self.view addGestureRecognizer:tap];
        if ([XPYReadConfigManager sharedInstance].pageType == XPYReadPageTypeNone) {
            // 无动画翻页模式添加左右滑动翻页事件
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
            [self.view addGestureRecognizer:pan];
        }
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_backView) {
        // 如果是背面，则将当前页面左右反转
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, -1, 1);
        self.view.transform = transform;
        self.view.alpha = 0.9;
    }
}

#pragma mark - UI
- (void)configureUI {
    [self.view addSubview:self.readView];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(-XPYReadViewRightSpacing);
        make.top.equalTo(self.view.mas_top).mas_offset(XPYReadViewTopSpacing);
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(-XPYReadViewBottomSpacing);
    }];
    
    [self.view addSubview:self.chapterNameLabel];
    [self.chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.bottom.equalTo(self.readView.mas_top).mas_offset(-10);
        make.width.equalTo(self.readView.mas_width).multipliedBy(0.5).mas_offset(-XPYReadViewLeftSpacing - 5);
    }];
    
    [self.view addSubview:self.currentPageLabel];
    [self.currentPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(-XPYReadViewRightSpacing);
        make.bottom.equalTo(self.readView.mas_top).mas_offset(-10);
    }];
}

#pragma mark - Instance methods
- (void)setupChapter:(XPYChapterModel *)chapter pageModel:(XPYChapterPageModel *)pageModel isBackView:(BOOL)isBackView {
    self.chapterModel = chapter;
    self.pageModel = [pageModel copy];
    [self.readView setupPageModel:self.pageModel chapter:self.chapterModel];
    [self.view setNeedsLayout];
    
    _backView = isBackView;
}

#pragma mark - Private methods
- (void)refreshInformationViews {
    self.chapterNameLabel.text = self.chapterModel.chapterName;
    self.currentPageLabel.text = [NSString stringWithFormat:@"第%@页/总%@页", @(self.pageModel.pageIndex + 1), @(self.chapterModel.pageModels.count)];
}

#pragma mark - Event response
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.view];
    // 限制点击翻页区域为屏幕左右，宽度为屏幕四分之一
    CGFloat width = CGRectGetWidth(self.view.bounds) / 4.0;
    
    if (touchPoint.x < width) {
        // 左边点击翻上一页
        if (self.delegate && [self.delegate respondsToSelector:@selector(readViewControllerShowLastPage)]) {
            [self.delegate readViewControllerShowLastPage];
        }
    } else if (touchPoint.x > width * 3) {
        // 右边点击翻下一页
        if (self.delegate && [self.delegate respondsToSelector:@selector(readViewControllerShowNextPage)]) {
            [self.delegate readViewControllerShowNextPage];
        }
    }
}
- (void)pan:(UIPanGestureRecognizer *)pan {
    // 滑动最短距离
    CGFloat distance = 10;
    CGPoint point = [pan translationInView:self.view];
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 滑动结束时判断滑动方向和距离
        if (point.x > distance) {
            // 向右滑动
            if (self.delegate && [self.delegate respondsToSelector:@selector(readViewControllerShowLastPage)]) {
                [self.delegate readViewControllerShowLastPage];
            }
        } else if (point.x < 0 && fabs(point.x) > distance) {
            // 向左滑动
            if (self.delegate && [self.delegate respondsToSelector:@selector(readViewControllerShowNextPage)]) {
                [self.delegate readViewControllerShowNextPage];
            }
        }
    }
}


#pragma mark - Getters
- (XPYReadView *)readView {
    if (!_readView) {
        _readView = [[XPYReadView alloc] initWithFrame:CGRectMake(XPYReadViewLeftSpacing, XPYReadViewTopSpacing, XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing, XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)];
    }
    return _readView;
}

- (UILabel *)chapterNameLabel {
    if (!_chapterNameLabel) {
        _chapterNameLabel = [[UILabel alloc] init];
        _chapterNameLabel.textColor = [XPYReadConfigManager sharedInstance].currentTextColor;
        _chapterNameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _chapterNameLabel;
}
- (UILabel *)currentPageLabel {
    if (!_currentPageLabel) {
        _currentPageLabel = [[UILabel alloc] init];
        _currentPageLabel.textColor = [XPYReadConfigManager sharedInstance].currentTextColor;
        _currentPageLabel.font = [UIFont systemFontOfSize:12];
    }
    return _currentPageLabel;
}

@end
