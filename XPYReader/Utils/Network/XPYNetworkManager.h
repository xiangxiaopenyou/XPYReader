//
//  XPYNetworkManager.h
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/1.
//  Copyright © 2020 xiang. All rights reserved.
//  使用单例二次封装AFNetworking的HTTP请求

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络状态block
typedef void (^XPYNetworkStatusBlock)(XPYNetworkStatus status);

/// 请求成功block
typedef void (^XPYRequestSuccessBlock)(id responseObject);

/// 请求失败block
typedef void (^XPYRequestFailureBlock)(NSError *error);

/// 请求进度block
typedef void (^XPYRequestProgressBlock)(NSProgress *progress);

@interface XPYNetworkManager : NSObject

+ (instancetype)sharedInstance;

/// 获取网络状态
- (void)networkStatusWithBlock:(XPYNetworkStatusBlock)networkStatus;

/**
 GET请求

 @param URLString 请求URL
 @param parameters 请求参数
 @param success 请求成功回调
 @param failure 请求失败回调
 @return 返回Task对象可取消请求
 */
- (nullable NSURLSessionTask *)getWithURL:(NSString *)URLString
               parameters:(NSDictionary *)parameters
                  success:(XPYRequestSuccessBlock)success
                  failure:(XPYRequestFailureBlock)failure;

/**
 POST请求

 @param URLString 请求URL
 @param parameters 请求参数
 @param success 请求成功回调
 @param failure 请求失败回调
 @return 返回Task对象可调用cancel方法取消请求
 */
- (nullable NSURLSessionTask *)postWithURL:(NSString *)URLString
                parameters:(NSDictionary *)parameters
                   success:(XPYRequestSuccessBlock)success
                   failure:(XPYRequestFailureBlock)failure;


/**
 上传文件

 @param URLString 请求URL
 @param parameters 请求参数
 @param bucketName 文件对应服务器上的字段
 @param filePath 文件本地沙盒路径
 @param progress 上传进度
 @param success 上传成功回调
 @param failure 上传失败回调
 @return 返回Task对象可调用cancel方法取消
 */
- (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                             bucketName:(NSString *)bucketName
                               filePath:(NSString *)filePath
                               progress:(XPYRequestProgressBlock)progress
                                success:(XPYRequestSuccessBlock)success
                                failure:(XPYRequestFailureBlock)failure;


/**
 下载文件

 @param URLString 请求URL
 @param fileDirectory 文件存储目录（默认为Download目录）
 @param progress 下载进度
 @param success 下载成功回调
 @param failure 下载失败回调
 @return 返回NSURLSessionDownloadTask实例，可暂停suspend 继续resume
 */
- (NSURLSessionTask *)downloadFileWithURL:(NSString *)URLString
                            fileDirectory:(NSString *)fileDirectory
                                 progress:(XPYRequestProgressBlock)progress
                                  success:(XPYRequestSuccessBlock)success
                                  failure:(XPYRequestFailureBlock)failure;

/// 请求超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 响应数据可接受类型集合
@property (nonatomic, strong) NSSet *responceAcceptableContentTypes;

/// 网络状态栏是否开启
@property (nonatomic, assign) BOOL networkActivityIndicatorEnable;

/// 是否打印log
@property (nonatomic, assign) BOOL logEnable;

@end

NS_ASSUME_NONNULL_END
