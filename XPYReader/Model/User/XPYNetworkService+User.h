//
//  XPYNetworkService+User.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYNetworkService (User)

/// 登录
/// @param phone 手机号
/// @param password 密码
/// @param success 成功回调
/// @param failure 失败回调
- (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure;

@end

NS_ASSUME_NONNULL_END
