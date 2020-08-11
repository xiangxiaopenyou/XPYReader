//
//  NSString+blowFish.m
//  zhangDu
//
//  Created by y on 2018/1/31.
//  Copyright © 2018年 ZD. All rights reserved.
//

#import "NSString+blowFish.h"

@implementation NSString (blowFish)

//核心代码
+ (NSData *)doBlowfish:(NSData *)dataIn
               context:(CCOperation)kCCEncrypt_or_kCCDecrypt
                   key:(NSData *)key
               options:(CCOptions)options
                    iv:(NSData *)iv
                 error:(NSError **)error
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeBlowfish];
    
    ccStatus = CCCrypt( kCCEncrypt_or_kCCDecrypt,
                       kCCAlgorithmBlowfish,
                       options,
                       key.bytes,
                       key.length,
                       (iv)?nil:iv.bytes,
                       dataIn.bytes,
                       dataIn.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {
        dataOut.length = cryptBytes;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError"
                                         code:ccStatus
                                     userInfo:nil];
        }
        dataOut = nil;
    }
    
    return dataOut;
}
//返回的是base64字符串-加密
- (NSString *)blowFishEncodingWithKey:(NSString *)pkey {
    if (pkey.length<8 || pkey.length>56) {
        NSLog(@"key值的长度必须在[8,56]之间");
        return nil;
    }
    NSError *error;
    NSData *key = [pkey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringOriginal = self;
    NSData *dataOriginal = [stringOriginal dataUsingEncoding:NSUTF8StringEncoding];;
    
    //    NSLog(@"key %@", key);
    //    NSLog(@"stringOriginal %@", stringOriginal);
    //    NSLog(@"dataOriginal   %@", dataOriginal);
    
    NSData *dataEncrypted = [NSString doBlowfish:dataOriginal
                                         context:kCCEncrypt
                                             key:key
                                         options:kCCOptionPKCS7Padding | kCCOptionECBMode
                                              iv:nil
                                           error:&error];
    //    NSLog(@"dataEncrypted  %@", dataEncrypted);
    
    NSString *encryptedBase64String = [dataEncrypted base64EncodedStringWithOptions:0];
    //    NSLog(@"encryptedBase64String  %@", encryptedBase64String);
    return encryptedBase64String;
}
//需要base64字符串调用，返回的是解密结果-解密
- (NSString *)blowFishDecodingWithKey:(NSString *)pkey {
    if (pkey.length<8 || pkey.length>56) {
        NSLog(@"key值的长度必须在[8,56]之间");
        return nil;
    }
    NSError *error;
    NSData *key = [pkey dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:self options:0];
    
    NSData *dataDecrypted = [NSString doBlowfish:dataToDecrypt
                                         context:kCCDecrypt
                                             key:key
                                         options:kCCOptionPKCS7Padding | kCCOptionECBMode
                                              iv:nil
                                           error:&error];
    //    NSLog(@"dataDecrypted  %@", dataDecrypted);
    
    NSString *stringDecrypted = [[NSString alloc] initWithData:dataDecrypted encoding:NSUTF8StringEncoding];
    //    NSLog(@"stringDecrypted %@", stringDecrypted);
    return stringDecrypted;
}

- (NSData *)blowFishPDFDecodingWithKey:(NSString *)pkey {
    if (pkey.length<8 || pkey.length>56) {
        NSLog(@"key值的长度必须在[8,56]之间");
        return nil;
    }
    NSError *error;
    NSData *key = [pkey dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:self options:0];
    
    NSData *dataDecrypted = [NSString doBlowfish:dataToDecrypt
                                         context:kCCDecrypt
                                             key:key
                                         options:kCCOptionPKCS7Padding | kCCOptionECBMode
                                              iv:nil
                                           error:&error];
    //    NSLog(@"dataDecrypted  %@", dataDecrypted);
    
    //    NSLog(@"stringDecrypted %@", stringDecrypted);
    return dataDecrypted;
}


@end
