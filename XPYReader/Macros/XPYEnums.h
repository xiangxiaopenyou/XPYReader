//
//  XPYEnums.h
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/1.
//  Copyright © 2020 xiang. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef XPYEnums_h
#define XPYEnums_h

/// 网络状态
typedef NS_ENUM(NSUInteger, XPYNetworkStatus) {
    XPYNetworkStatusUnknown,        // 未知网络
    XPYNetworkStatusUnreachable,    // 没有网络
    XPYNetworkStatusReachableWWAN,  // 手机网络
    XPYNetworkStatusReachableWiFi   // WiFi网络
};

/// 网络请求方式
typedef NS_ENUM(NSUInteger, XPYHTTPRequestType) {
    XPYHTTPRequestTypeGet,          // GET
    XPYHTTPRequestTypePost,         // POST
    XPYHTTPRequestTypeUploadFile,   // Upload
    XPYHTTPRequestTypeDownloadFile  // Download
};

#endif /* XPYEnums_h */
