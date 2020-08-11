//
//  XPYBookStoreCell.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/11.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@interface XPYBookStoreCell : UITableViewCell

- (void)setupData:(XPYBookModel *)bookModel;

@end

NS_ASSUME_NONNULL_END
