//
//  XPYReadConfigManager.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadConfigManager.h"

@implementation XPYReadConfigManager

+ (instancetype)sharedInstance {
    static XPYReadConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id config = [[NSUserDefaults standardUserDefaults] objectForKey:XPYReadConfigKey];
        instance = [XPYReadConfigManager yy_modelWithJSON:config];
        if (!instance) {
            instance = [[XPYReadConfigManager alloc] init];
            instance.lineSpacing = 3;
            instance.paragraphSpacing = 10;
            instance.fontSize = 19;
            instance.pageType = XPYReadPageTypeCurl;
        }
    });
    return instance;
}

/// 更新本地阅读配置
- (void)updateConfigs {
    [[NSUserDefaults standardUserDefaults] setObject:[self yy_modelToJSONObject] forKey:XPYReadConfigKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPageType:(XPYReadPageType)pageType {
    _pageType = pageType;
    [self updateConfigs];
}

@end
