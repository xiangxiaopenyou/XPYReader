//
//  XPYNetworkManager.m
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/1.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkManager.h"

#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>

@interface XPYNetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableArray *tasksArray;

@end

@implementation XPYNetworkManager

/// 第一次收到消息时开始监听网络状态变化
+ (void)initialize {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (instancetype)sharedInstance {
    static XPYNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XPYNetworkManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPSessionManager alloc] init];
        // 默认请求超时时间30
        self.manager.requestSerializer.timeoutInterval = 30;
        // 默认响应数据可接受类型集合
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
        // 默认可使用不受信任证书
        self.manager.securityPolicy.allowInvalidCertificates = YES;
        // 默认不验证域名
        self.manager.securityPolicy.validatesDomainName = NO;
        // 网络状态栏默认开启
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        // 默认打印log
        _logEnable = YES;
    }
    return self;
}

#pragma mark - Instance methods
- (void)networkStatusWithBlock:(XPYNetworkStatusBlock)networkStatus {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {
                networkStatus ? networkStatus(XPYNetworkStatusUnknown) : nil;
                if (self.logEnable) {
                    NSLog(@"未知网络");
                }
            }
                break;
            case AFNetworkReachabilityStatusNotReachable: {
                networkStatus ? networkStatus(XPYNetworkStatusUnreachable) : nil;
                if (self.logEnable) {
                    NSLog(@"没有网络");
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                networkStatus ? networkStatus(XPYNetworkStatusReachableWWAN) : nil;
                if (self.logEnable) {
                    NSLog(@"手机网络");
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                networkStatus ? networkStatus(XPYNetworkStatusReachableWiFi) : nil;
                if (self.logEnable) {
                    NSLog(@"WiFi");
                }
            }
                break;
                
            default:
                break;
        }
    }];
}

- (NSURLSessionTask *)getWithURL:(NSString *)URLString
               parameters:(NSDictionary *)parameters
                  success:(XPYRequestSuccessBlock)success
                  failure:(XPYRequestFailureBlock)failure {
    if (self.logEnable) {
        NSLog(@"\nURL:%@\nparams:%@", URLString, parameters);
    }
    NSURLSessionTask *sessionTask = [self.manager GET:URLString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (self.logEnable) {
            NSLog(@"responseObject = %@", responseObject);
        }
        [self.tasksArray removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.logEnable) {
            NSLog(@"error = %@", error);
        }
        [self.tasksArray removeObject:task];
        failure ? failure(error) : nil;
    }];
    //添加task到数组
    sessionTask ? [self.tasksArray addObject:sessionTask] : nil;
    return sessionTask;
}

- (NSURLSessionTask *)postWithURL:(NSString *)URLString
                parameters:(NSDictionary *)parameters
                   success:(XPYRequestSuccessBlock)success
                   failure:(XPYRequestFailureBlock)failure {
    if (self.logEnable) {
        NSLog(@"\nURL:%@\nparams:%@", URLString, parameters);
    }
    NSURLSessionTask *sessionTask = [self.manager POST:URLString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (self.logEnable) {
            NSLog(@"responseObject = %@", responseObject);
        }
        [self.tasksArray removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.logEnable) {
            NSLog(@"error = %@", error);
        }
        [self.tasksArray removeObject:task];
        failure ? failure(error) : nil;
    }];
    //添加task到数组
    sessionTask ? [self.tasksArray addObject:sessionTask] : nil;
    return sessionTask;
}

- (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                             bucketName:(NSString *)bucketName
                               filePath:(NSString *)filePath
                               progress:(XPYRequestProgressBlock)progress
                                success:(XPYRequestSuccessBlock)success
                                failure:(XPYRequestFailureBlock)failure {
    if (self.logEnable) {
        NSLog(@"\nURL:%@\nparams:%@\nbucketName:%@\nfilePath:%@", URLString, parameters, bucketName, filePath);
    }
    NSURLSessionTask *sessionTask = [self.manager POST:URLString parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:bucketName error:&error];
        if (failure && error) {
            if (self.logEnable) {
                NSLog(@"error = %@", error);
            }
            failure(error);
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (self.logEnable) {
            NSLog(@"progress = %@", uploadProgress);
        }
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (self.logEnable) {
            NSLog(@"responseObject = %@", responseObject);
        }
        [self.tasksArray removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.logEnable) {
            NSLog(@"error = %@", error);
        }
        [self.tasksArray removeObject:task];
        failure ? failure(error) : nil;
    }];
    return sessionTask;
}

- (NSURLSessionTask *)downloadFileWithURL:(NSString *)URLString
                            fileDirectory:(NSString *)fileDirectory
                                 progress:(XPYRequestProgressBlock)progress
                                  success:(XPYRequestSuccessBlock)success
                                  failure:(XPYRequestFailureBlock)failure {
    if (self.logEnable) {
        NSLog(@"\nURL:%@\n fileDirectory:%@", URLString, fileDirectory);
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    __block NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (self.logEnable) {
            NSLog(@"progress = %@", downloadProgress);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:fileDirectory ? fileDirectory : @"Download"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [directoryPath stringByAppendingPathComponent:response.suggestedFilename];
        if (self.logEnable) {
            NSLog(@"destinationPath = %@", filePath);
        }
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self.tasksArray removeObject:downloadTask];
        if (failure && error) {
            if (self.logEnable) {
                NSLog(@"error = %@", error);
            }
            failure(error);
            return;
        }
        if (self.logEnable) {
            NSLog(@"responseObject = %@", response);
        }
        success ? success(filePath.absoluteString) : nil;
    }];
    [downloadTask resume];
    downloadTask ? [self.tasksArray addObject:downloadTask] : nil;
    return downloadTask;
}


#pragma mark - Setters
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    self.manager.requestSerializer.timeoutInterval = timeoutInterval;
}
- (void)setResponceAcceptableContentTypes:(NSSet *)responceAcceptableContentTypes {
    if (responceAcceptableContentTypes.count > 0) {
        self.manager.responseSerializer.acceptableContentTypes = responceAcceptableContentTypes;
    }
}
- (void)setNetworkActivityIndicatorEnable:(BOOL)networkActivityIndicatorEnable {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = networkActivityIndicatorEnable;
}
- (void)setLogEnable:(BOOL)logEnable {
    self.logEnable = logEnable;
}

#pragma mark - Getters
- (NSMutableArray *)tasksArray {
    if (!_tasksArray) {
        _tasksArray = [[NSMutableArray alloc] init];
    }
    return _tasksArray;
}

@end
