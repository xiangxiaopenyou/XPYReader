//
//  XPYReadConfigManager.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadConfigManager.h"

@interface XPYReadConfigManager ()

@property (nonatomic, assign) NSInteger lightColorIndex;
@property (nonatomic, assign) NSInteger darkColorIndex;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger spacingLevel;
@property (nonatomic, assign) XPYReadPageType pageType;
@property (nonatomic, assign) XPYAutoReadMode autoReadMode;
@property (nonatomic, assign) NSInteger autoReadSpeed;

@end

@implementation XPYReadConfigManager

+ (instancetype)sharedInstance {
    static XPYReadConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id config = [[NSUserDefaults standardUserDefaults] objectForKey:XPYReadConfigKey];
        instance = [XPYReadConfigManager yy_modelWithJSON:config];
        // 自动阅读模式默认关闭
        instance.isAutoRead = NO;
        if (!instance) {
            instance = [[XPYReadConfigManager alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:[instance yy_modelToJSONObject] forKey:XPYReadConfigKey];
        }
    });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.lightColorIndex = 0;
        self.darkColorIndex = 5;
        self.spacingLevel = 3;
        self.fontSize = 19;
        self.pageType = XPYReadPageTypeCurl;
        // 自动阅读模式默认关闭
        self.isAutoRead = NO;
        // 默认自动阅读滚屏模式
        self.autoReadMode = XPYAutoReadModeScroll;
        self.autoReadSpeed = XPYDefaultAutoReadSpeed;
    }
    return self;
}

- (BOOL)isDarkMode {
    NSInteger index = [self currentColorIndex];
    if (index == 2 || index == 4 || index == 5) {
        return YES;
    }
    return NO;
}

- (NSInteger)currentColorIndex {
    return [XPYUtilities isDarkUserInterfaceStyle] ? self.darkColorIndex : self.lightColorIndex;
}

- (UIColor *)currentBackgroundColor {
    NSInteger index = [self currentColorIndex];
    NSArray *colors = [@[XPYReadBackgroundColor1, XPYReadBackgroundColor2, XPYReadBackgroundColor3, XPYReadBackgroundColor4, XPYReadBackgroundColor5, XPYReadBackgroundColor6] copy];
    return colors[index];
}

- (UIColor *)currentTextColor {
    // 当前文字颜色可以自行设置，这里只简单设置了两种
    return [self isDarkMode] ? XPYColorFromHexWithAlpha(0xFFFFFF, 0.5) : XPYColorFromHex(0x333333);
}

- (void)updateColorIndex:(NSInteger)colorIndex {
    if ([XPYUtilities isDarkUserInterfaceStyle]) {
        self.darkColorIndex = colorIndex;
    } else {
        self.lightColorIndex = colorIndex;
    }
    [self updateConfigs];
}

- (void)updatePageType:(XPYReadPageType)pageType {
    self.pageType = pageType;
    [self updateConfigs];
}

- (void)updateFontSizeWithSize:(NSInteger)size {
    self.fontSize = size;
    [self updateConfigs];
}

- (void)updateSpacingLevel:(NSInteger)level {
    self.spacingLevel = level;
    [self updateConfigs];
}

- (void)updateAutoReadMode:(XPYAutoReadMode)mode {
    self.autoReadMode = mode;
    [self updateConfigs];
}

/// 更新本地阅读配置
- (void)updateConfigs {
    [[NSUserDefaults standardUserDefaults] setObject:[self yy_modelToJSONObject] forKey:XPYReadConfigKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
