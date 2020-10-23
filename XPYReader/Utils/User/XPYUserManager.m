//
//  XPYUserManager.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYUserManager.h"

@interface XPYUserManager ()

@property (nonatomic, strong) XPYUserModel *currentUser;
@property (nonatomic, assign) BOOL isLogin;

@end

@implementation XPYUserManager

+ (instancetype)sharedInstance {
    static XPYUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XPYUserManager alloc] init];
    });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:XPYUserCacheKey]) {
            self.currentUser = [XPYUserModel yy_modelWithJSON:[[NSUserDefaults standardUserDefaults] dictionaryForKey:XPYUserCacheKey]];
        } else {
            self.currentUser = nil;
        }
        _isLogin = !XPYIsEmptyObject(self.currentUser);
    }
    return self;
}

- (void)saveUser:(XPYUserModel *)user {
    if (XPYIsEmptyObject(user)) {
        return;
    }
    NSDictionary *userDictionary = [user yy_modelToJSONObject];
    [[NSUserDefaults standardUserDefaults] setObject:userDictionary forKey:XPYUserCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentUser = user;
    _isLogin = YES;
}

- (void)deleteCurrentUser {
    if (XPYIsEmptyObject(self.currentUser)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:XPYUserCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentUser = nil;
    _isLogin = NO;
}

@end
