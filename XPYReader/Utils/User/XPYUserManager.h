//
//  XPYUserManager.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPYUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYUserManager : NSObject

+ (instancetype)sharedInstance;

/// 保存用户信息
/// @param user 用户信息Model
- (void)saveUser:(XPYUserModel *)user;

/// 删除当前用户信息
- (void)deleteCurrentUser;

/// 当前登录用户信息
@property (nonatomic, strong, readonly) XPYUserModel *currentUser;

/// 是否登录
@property (nonatomic, assign, readonly) BOOL isLogin;

@end

NS_ASSUME_NONNULL_END
