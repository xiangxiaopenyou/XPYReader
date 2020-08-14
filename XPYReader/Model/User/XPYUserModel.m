//
//  XPYUserModel.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYUserModel.h"

@implementation XPYUserModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"userId" : @"user_id",
        @"phone" : @"tel",
        @"avatarURL" : @"imgurl"
    };
}

@end
