//
//  XPYNetworkService+User.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/14.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService+User.h"
#import "XPYUserModel.h"

@implementation XPYNetworkService (User)

- (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypePost path:@"user?action=login" parameters:@{@"type" : @"login_by_pwd", @"tel" : phone, @"password" : password} success:^(id result) {
        XPYUserModel *userModel = [XPYUserModel yy_modelWithJSON:result];
        !success ?: success(userModel);
    } failure:^(NSError *error) {
        !failure ?: failure(error);
    }];
}

@end
