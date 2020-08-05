//
//  XPYBaseModel.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseModel.h"

@implementation XPYBaseModel

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self yy_modelEncodeWithCoder:coder];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self yy_modelInitWithCoder:coder];
}

- (NSUInteger)hash {
    return [self yy_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (NSArray *)modelArrayWithJSON:(id)json {
    if (!json) {
        return nil;
    }
    return [NSArray yy_modelArrayWithClass:[self class] json:json];
}

@end
