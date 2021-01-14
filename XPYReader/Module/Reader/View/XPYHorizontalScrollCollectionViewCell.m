//
//  XPYHorizontalScrollCollectionViewCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYHorizontalScrollCollectionViewCell.h"
#import "XPYReadView.h"

#import "XPYChapterModel.h"
#import "XPYChapterPageModel.h"

@interface XPYHorizontalScrollCollectionViewCell ()

@property (nonatomic, strong) XPYReadView *readView;
/// 章节名
@property (nonatomic, strong) UILabel *chapterNameLabel;
/// 当前页码
@property (nonatomic, strong) UILabel *currentPageLabel;

@end

@implementation XPYHorizontalScrollCollectionViewCell

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.readView];
        [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).mas_offset(XPYReadViewLeftSpacing);
            make.top.equalTo(self.contentView.mas_top).mas_offset(XPYReadViewTopSpacing);
            make.trailing.equalTo(self.contentView.mas_trailing).mas_offset(- XPYReadViewRightSpacing);
            make.bottom.equalTo(self.contentView.mas_bottom).mas_offset(- XPYReadViewBottomSpacing);
        }];
        
        [self.contentView addSubview:self.chapterNameLabel];
        [self.chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).mas_offset(XPYReadViewLeftSpacing);
            make.bottom.equalTo(self.readView.mas_top).mas_offset(-10);
            make.width.equalTo(self.readView.mas_width).multipliedBy(0.5).mas_offset(-XPYReadViewLeftSpacing - 5);
        }];
        
        [self.contentView addSubview:self.currentPageLabel];
        [self.currentPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView.mas_trailing).mas_offset(-XPYReadViewRightSpacing);
            make.bottom.equalTo(self.readView.mas_top).mas_offset(-10);
        }];
    }
    return self;
}

#pragma mark - Instance methods
- (void)setupChapter:(XPYChapterModel *)chapter pageModel:(XPYChapterPageModel *)pageModel {
    [self.readView setupPageModel:pageModel chapter:chapter];
    self.chapterNameLabel.text = chapter.chapterName;
    self.currentPageLabel.text = [NSString stringWithFormat:@"第%@页/总%@页", @(pageModel.pageIndex + 1), @(chapter.pageModels.count)];
}

#pragma mark - Getters
- (XPYReadView *)readView {
    if (!_readView) {
        _readView = [[XPYReadView alloc] initWithFrame:CGRectMake(XPYReadViewLeftSpacing, XPYReadViewTopSpacing, XPYReadViewWidth, XPYReadViewHeight)];
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
