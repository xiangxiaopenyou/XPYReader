//
//  XPYBookStoreCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookStoreCell.h"

#import "XPYBookModel.h"

@interface XPYBookStoreCell ()

@property (nonatomic, strong) UIImageView *bookImageView;
@property (nonatomic, strong) UILabel *bookLabel;

@end

@implementation XPYBookStoreCell

#pragma mark - Initializer
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.bookImageView];
        [self.bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).with.mas_offset(15);
            make.top.equalTo(self.contentView.mas_top).with.mas_offset(15);
            make.size.mas_offset(CGSizeMake(75, 100));
        }];
        
        [self.contentView addSubview:self.bookLabel];
        [self.bookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bookImageView.mas_trailing).with.mas_offset(12);
            make.trailing.equalTo(self.contentView.mas_trailing).mas_offset(15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setupData:(XPYBookModel *)bookModel {
    [self.bookImageView sd_setImageWithURL:[NSURL URLWithString:bookModel.bookCoverURL]];
    self.bookLabel.text = bookModel.bookName;
}

#pragma mark - Getters
- (UIImageView *)bookImageView {
    if (!_bookImageView) {
        _bookImageView = [[UIImageView alloc] init];
    }
    return _bookImageView;
}
- (UILabel *)bookLabel {
    if (!_bookLabel) {
        _bookLabel = [[UILabel alloc] init];
        _bookLabel.textColor = [UIColor blackColor];
        _bookLabel.font = [UIFont systemFontOfSize:15];
    }
    return _bookLabel;
}

@end
