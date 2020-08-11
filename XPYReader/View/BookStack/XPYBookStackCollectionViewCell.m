//
//  XPYBookStackCollectionViewCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookStackCollectionViewCell.h"

#import "XPYBookModel.h"

@interface XPYBookStackCollectionViewCell ()

@property (nonatomic, strong) UIImageView *bookCoverImageView;
@property (nonatomic, strong) UILabel *bookNameLabel;

@end

@implementation XPYBookStackCollectionViewCell

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bookCoverImageView];
        [self.contentView addSubview:self.bookNameLabel];
        [self.bookCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 30, 0));
        }];
        
        [self.bookNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.contentView);
            make.top.equalTo(self.bookCoverImageView.mas_bottom);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

#pragma mark - Instance methods
- (void)setupData:(XPYBookModel *)book {
    if (!book) {
        return;
    }
    [self.bookCoverImageView sd_setImageWithURL:[NSURL URLWithString:book.bookCoverURL]];
    self.bookNameLabel.text = book.bookName;
    
}

#pragma mark - Getters
- (UIImageView *)bookCoverImageView {
    if (!_bookCoverImageView) {
        _bookCoverImageView = [[UIImageView alloc] init];
    }
    return _bookCoverImageView;
}
- (UILabel *)bookNameLabel {
    if (!_bookNameLabel) {
        _bookNameLabel = [[UILabel alloc] init];
        _bookNameLabel.font = [UIFont systemFontOfSize:13];
        _bookNameLabel.textColor = [UIColor blackColor];
    }
    return _bookNameLabel;
}

@end
