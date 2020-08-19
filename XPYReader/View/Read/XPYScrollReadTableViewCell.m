//
//  XPYScrollReadTableViewCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYScrollReadTableViewCell.h"
#import "XPYReadView.h"

@interface XPYScrollReadTableViewCell ()

@property (nonatomic, strong) XPYReadView *scrollReadView;

@end

@implementation XPYScrollReadTableViewCell

#pragma mark - Initializer
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.scrollReadView];
        [self.scrollReadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

#pragma mark - Instance methods
- (void)setupContent:(NSAttributedString *)contentString {
    if (XPYIsEmptyObject(contentString)) {
        return;
    }
    [self.scrollReadView setupContent:contentString];
    [self.contentView layoutIfNeeded];
}

#pragma mark - Getters
- (XPYReadView *)scrollReadView {
    if (!_scrollReadView) {
        _scrollReadView = [[XPYReadView alloc] initWithFrame:CGRectZero];
    }
    return _scrollReadView;
}

@end
