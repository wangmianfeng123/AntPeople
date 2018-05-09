//
//  NSString+CJAES.m
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import "NSString+CJAES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"


@implementation NSString (CJAES)


/**
 加密
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSString *)AESEncryptStrWithKey:(NSString *)keyStr
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *AESData = [self AES128Operation:kCCEncrypt data:data withKey:keyStr];
    
    NSString *AESStr = [self encodeBase64Data:AESData];
    
    return AESStr;
}


/**
 解密
 
 @param keyStr 密钥
 @return 解密结果
 */
- (NSString *)AESDecryptStrWithKey:(NSString *)keyStr
{
    NSArray *dataArray = [self componentsSeparatedByString:@"_"];
    NSMutableData *ddData = [[NSMutableData alloc] init];
    
    for (int i = 0; i < dataArray.count; i++) {
        NSString *eeeStr = dataArray[i];
        NSData *data = [eeeStr dataUsingEncoding:NSUTF8StringEncoding];
        NSData *gData = [self decodeBase64Data:data];
        NSData *gAESData = [self AES128Operation:kCCDecrypt data:gData withKey:keyStr];
        [ddData appendData:gAESData];
        
    }
    NSString *gDecStr = [[NSString alloc] initWithData:ddData encoding:NSUTF8StringEncoding];
    
    return gDecStr;
}

/**
 加密 [Json字符串加密]
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSString *)AESEncryptJsonStrWithKey:(NSString *)keyStr
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *encryptData = [self AES128Encrypt:base64String withKey:keyStr];
    NSString *encryptStr = [self encodeBase64Data:encryptData];
    
    return encryptStr;
}


- (NSData *)AES128Operation:(CCOperation)operation data:(NSData *)data withKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [key getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptorStatus = CCCrypt(operation,
                                            kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr,
                                            kCCKeySizeAES128,
                                            ivPtr,
                                            [data bytes],
                                            [data length],
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

- (NSString *)encodeBase64String:(NSString * )input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

// GTMBase64编码
- (NSString*)encodeBase64Data:(NSData *)data
{
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

// GTMBase64解码
- (NSData*)decodeBase64Data:(NSData *)data {
    data = [GTMBase64 decodeData:data];
    return data;
}

// ------
/**
 加密
 
 @param plainText 加密文件[base64加密后的字符串]
 @param key 密钥
 @return 加密数据
 */
- (NSData *)AES128Encrypt:(NSString *)plainText withKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [key getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    NSUInteger diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    NSUInteger newSize = 0;
    
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x0000; // 注意 No padding
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptorStatus = CCCrypt(kCCEncrypt,
                                            kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr,
                                            kCCKeySizeAES128,
                                            ivPtr,
                                            dataPtr,
                                            sizeof(dataPtr),
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

