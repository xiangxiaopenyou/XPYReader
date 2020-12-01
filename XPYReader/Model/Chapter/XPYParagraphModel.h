//
//  XPYParagraphModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/11/30.
//  Copyright © 2020 xiang. All rights reserved.
//  段落数据模型

#import "XPYBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYParagraphModel : XPYBaseModel

/// 段落内容
@property (nonatomic, copy) NSString *content;
/// 段落内容范围
@property (nonatomic, assign) NSRange range;
/// 段落编号
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
