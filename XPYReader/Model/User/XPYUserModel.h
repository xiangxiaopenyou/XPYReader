//
//  XPYUserModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYUserModel : XPYBaseModel

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *avatarURL;

@end

NS_ASSUME_NONNULL_END
