//
//  XPYBookStackCollectionViewCell.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYBookStackCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *bookCoverImageView;

- (void)setupData:(XPYBookModel *)book;

@end

NS_ASSUME_NONNULL_END
