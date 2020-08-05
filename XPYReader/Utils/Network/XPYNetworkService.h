//
//  XPYNetworkService.h
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/2.
//  Copyright © 2020 xiang. All rights reserved.
//  网络请求服务类，实现XPYNetworkServiceProtocol协议

#import <Foundation/Foundation.h>

@class XPYNetworkManager;

NS_ASSUME_NONNULL_BEGIN

@interface XPYNetworkService : NSObject

/// 使用单例
+ (instancetype)sharedService;


/// 普通网络请求
/// @param type 请求类型(GET或者POST)
/// @param path 请求路径(拼接在BaseURL后面)
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (void)request:(XPYHTTPRequestType)type
           path:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(XPYSuccessHandler)success
        failure:(XPYFailureHandler)failure;


@property (nonatomic, strong, readonly) XPYNetworkManager *manager;

@end

NS_ASSUME_NONNULL_END
