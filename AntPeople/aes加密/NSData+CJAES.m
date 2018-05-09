//
//  NSData+CJAES.m
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import "NSData+CJAES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (CJAES)


/**
 加密
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSData *)AESEncryptWithKey:(NSString *)keyStr
{
    NSData *encryptData = [self AES128Operation:kCCEncrypt withKey:keyStr];
    
    return encryptData;
}


/**
 解密
 
 @param keyStr 密钥
 @return 解密结果
 */
- (NSData *)AESDecryptWithKey:(NSString *)keyStr
{
    NSData *decryptData = [self AES128Operation:kCCEncrypt withKey:keyStr];
    
    return decryptData;
}


- (NSData *)AES128Operation:(CCOperation)operation withKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [key getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptorStatus = CCCrypt(operation,
                                            kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr,
                                            kCCKeySizeAES128,
                                            ivPtr,
                                            [self bytes],
                                            dataLength,
                                            buffer,
                                            bufferSize,
                                            &numBytesEncrypted);
    if (cryptorStatus == kCCSuccess) {
        NSLog(@"cryptorStatus == kCCSuccess");
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    } else {
        NSLog(@"cryptorStatus == Error");
    }
    free(buffer);
    return nil;
}



@end
