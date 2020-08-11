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
            instance.textColor = [UIColor blackColor];
        }
    });
    return instance;
}

@end
