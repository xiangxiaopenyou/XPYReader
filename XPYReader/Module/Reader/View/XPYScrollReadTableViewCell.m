//
//  XPYScrollReadTableViewCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYScrollReadTableViewCell.h"
#import "XPYReadView.h"

#import "XPYChapterPageModel.h"

@interface XPYScrollReadTableViewCell ()

@property (nonatomic, strong) XPYReadView *scrollReadView;

@end

@implementation XPYScrollReadTableViewCell

#pragma mark - Initializer
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.scrollReadView];
        [self.scrollReadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

#pragma mark - Instance methods
- (void)setupChapterPageModel:(XPYChapterPageModel *)pageModel chapterModel:(XPYChapterModel *)chapterModel {
    if (!pageModel) {
        return;
    }
    [self.scrollReadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        // 头部留间距
        make.top.equalTo(self.contentView.mas_top).mas_offset(pageModel.extraHeaderHeight);
    }];
    [self.scrollReadView setupPageModel:pageModel chapter:chapterModel];
}

#pragma mark - Getters
- (XPYReadView *)scrollReadView {
    if (!_scrollReadView) {
        _scrollReadView = [[XPYReadView alloc] initWithFrame:CGRectMake(0, 0, XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing, XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)];
    }
    return _scrollReadView;
}

@end
