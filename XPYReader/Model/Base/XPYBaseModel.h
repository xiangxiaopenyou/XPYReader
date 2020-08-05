//
//  XPYBaseModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYBaseModel : NSObject <YYModel, NSCopying, NSSecureCoding>

+ (NSArray *)modelArrayWithJSON:(id)json;

@end

NS_ASSUME_NONNULL_END
