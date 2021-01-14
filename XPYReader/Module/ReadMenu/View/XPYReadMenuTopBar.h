//
//  XPYReadMenuTopBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XPYReadMenuTopBarDelegate <NSObject>

- (void)topBarDidClickBack;

@end

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadMenuTopBar : UIView

@property (nonatomic, weak) id <XPYReadMenuTopBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
