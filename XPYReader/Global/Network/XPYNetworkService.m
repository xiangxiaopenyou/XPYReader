//
//  XPYNetworkService.m
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/2.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService.h"
#import "XPYNetworkManager.h"
#import "XPYUserManager.h"

/// 示例BaseURL
#if DEBUG
static NSString * const kXPYBaseURL = @"http://testapp.xxpy.com/v1";
#else
static NSString * const kXPYBaseURL = @"http://app.xxpy.com/v1";
#endif


@interface XPYNetworkService ()

@property (nonatomic, strong) XPYNetworkManager *manager;

@end

@implementation XPYNetworkService

+ (instancetype)sharedService {
    static XPYNetworkService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[XPYNetworkService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [XPYNetworkManager sharedInstance];
    }
    return self;
}

#pragma mark - Private methods
/// 获取完整请求链接
/// @param path 路径
/// @param type 请求类型
- (NSString *)completeRequestURLStringWithPath:(NSString *)path requestType:(XPYHTTPRequestType)type {
    return path ? [kXPYBaseURL stringByAppendingPathComponent:path] : kXPYBaseURL;
}

/// 获取完整的请求参数（为了拼接统一参数，如ID、Token）
/// @param params 接口传入参数
- (NSDictionary *)completeParametersWithParams:(NSDictionary *)params {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:params];
    // 先判断是否已经登录(根据需求自由发挥，这里传了userId和token)
    if ([XPYUserManager sharedInstance].isLogin) {
        [temp setObject:[XPYUserManager sharedInstance].currentUser.userId forKey:@"user_id"];
        [temp setObject:[XPYUserManager sharedInstance].currentUser.token forKey:@"token"];
    }
    return (NSDictionary *)[temp copy];
}

/// 解析数据
/// @param responseObject 返回数据，返回数据格式可以自己跟服务器沟通，以下代码都是示例作用
- (id)resultWithResponseObject:(id)responseObject {
    if (!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
        // 返回为空或者返回格式不正确时的错误代码可自行设计，暂时设为-1
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:@{NSUnderlyingErrorKey : @"返回格式错误"}];
        return error;
    }
    if ([responseObject[@"errno"] integerValue] == 0) {    //上述例子中当errno为0时请求成功，反之则有各种错误，错误代码可与服务端沟通
        return responseObject[@"data"];     //上述例子中把接口数据放在data中
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:[responseObject[@"errno"] integerValue] userInfo:@{NSUnderlyingErrorKey : responseObject[@"msg"]}];
        return error;
    }
}

#pragma mark - Instance methods
- (void)request:(XPYHTTPRequestType)type path:(NSString *)path parameters:(NSDictionary *)parameters success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    if (type == XPYHTTPRequestTypeGet) {
        [self.manager getWithURL:[self completeRequestURLStringWithPath:path requestType:type] parameters:[self completeParametersWithParams:parameters] success:^(id  _Nonnull responseObject) {
            id result = [self resultWithResponseObject:responseObject];
            if ([result isMemberOfClass:[NSError class]]) {
                if (failure) {
                    failure(result);
                }
            } else {
                if (success) {
                    success(result);
                }
            }
        } failure:^(NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }
        }];
    } else if (type == XPYHTTPRequestTypePost) {
        [self.manager postWithURL:[self completeRequestURLStringWithPath:path requestType:type] parameters:[self completeParametersWithParams:parameters] success:^(id  _Nonnull responseObject) {
            id result = [self resultWithResponseObject:responseObject];
            if ([result isMemberOfClass:[NSError class]]) {
                if (failure) {
                    failure(result);
                }
            } else {
                if (success) {
                    success(result);
                }
            }
        } failure:^(NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

@end
