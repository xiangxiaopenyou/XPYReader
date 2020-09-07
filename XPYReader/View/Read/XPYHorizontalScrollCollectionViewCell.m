//
//  XPYHorizontalScrollCollectionViewCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYHorizontalScrollCollectionViewCell.h"
#import "XPYReadView.h"

#import "XPYChapterPageModel.h"

@interface XPYHorizontalScrollCollectionViewCell ()

@property (nonatomic, strong) XPYReadView *readView;

@end

@implementation XPYHorizontalScrollCollectionViewCell

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
    }
    return self;
}

- (void)setupChapter:(XPYChapterModel *)chapter pageModel:(XPYChapterPageModel *)pageModel {
    [self.readView setupContent:pageModel.pageContent];
}

#pragma mark - Getters
- (XPYReadView *)readView {
    if (!_readView) {
        _readView = [[XPYReadView alloc] initWithFrame:CGRectMake(XPYReadViewLeftSpacing, XPYReadViewTopSpacing, XPYReadViewWidth, XPYReadViewHeight)];
    }
    return _readView;
}

@end
