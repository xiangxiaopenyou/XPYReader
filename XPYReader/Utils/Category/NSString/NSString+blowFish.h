//
//  NSString+blowFish.h
//  zhangDu
//
//  Created by y on 2018/1/31.
//  Copyright © 2018年 ZD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSString (blowFish)

- (NSString *)blowFishDecodingWithKey:(NSString *)pkey;
- (NSData *)blowFishPDFDecodingWithKey:(NSString *)pkey;
+ (NSData *)doBlowfish:(NSData *)dataIn
               context:(CCOperation)kCCEncrypt_or_kCCDecrypt
                   key:(NSData *)key
               options:(CCOptions)options
                    iv:(NSData *)iv
                 error:(NSError **)error;
@end
