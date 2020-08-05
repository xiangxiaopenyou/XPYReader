//
//  XPYBlocks.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/5.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef XPYBlocks_h
#define XPYBlocks_h

typedef void (^XPYVoidHandler)(void);

typedef void (^XPYSuccessHandler)(id result);

typedef void (^XPYFailureHandler)(NSError *error);

#endif /* XPYBlocks_h */
