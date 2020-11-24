//
//  XPYNetworkService+User.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService+User.h"
#import "XPYUserModel.h"

static NSString * const kXPYUserLoginURL = @"/user/login";

@implementation XPYNetworkService (User)

- (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypePost path:kXPYUserLoginURL parameters:@{} success:^(id result) {
        XPYUserModel *userModel = [XPYUserModel yy_modelWithJSON:result];
        !success ?: success(userModel);
    } failure:^(NSError *error) {
        !failure ?: failure(error);
    }];
}

@end
