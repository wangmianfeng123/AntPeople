//
//  NSDictionary+CJAES.m
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import "NSDictionary+CJAES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation NSDictionary (CJAES)



/**
 加密
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSString *)AESEncrypt:(NSDictionary *)plainDict withKey:(NSString *)keyStr
{
    NSString *jsonStr = [self dictionaryToJson:plainDict];
    NSString *base64Str = [self encodeBase64String:jsonStr];
    NSData *encryptData = [self AES128Encrypt:base64Str withKey:keyStr];
    NSString *encryptStr = [self encodeBase64Data:encryptData];
    
    return encryptStr;
}


/**
 解密专换成字典
 
 @param keyStr 密钥
 @return 解密结果
 */
- (NSDictionary *)AESDecrypt:(NSString *)base64Str withKey:(NSString *)keyStr
{
    NSData *decData = [self AES128Decrypt:base64Str withKey:keyStr];
    
    NSString *decStr = [self decodeBase64Data:decData];
    
    NSDictionary *dict = [self dictionaryWithJsonString:decStr];
    
    return dict;
}

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



/**
 解密

 @param encryptText 解密文件[base64编码字符串]
 @param key 密钥
 @return 解密结果
 */
- (NSData *)AES128Decrypt:(NSString *)encryptText withKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [key getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptorStatus = CCCrypt(kCCDecrypt,
                                            kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr,
                                            kCCBlockSizeAES128,
                                            ivPtr,
                                            [data bytes],
                                            dataLength,
                                            buffer,
                                            bufferSize,
                                            &numBytesDecrypted);
    if (cryptorStatus == kCCSuccess) {
        NSLog(@"cryptorStatus == kCCSuccess");
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    } else {
        NSLog(@"cryptorStatus == Error");
    }
    free(buffer);
    return nil;
}


/**
 将字典转换成Json字符串

 @param dict 字典
 @return Json字符串
 */
- (NSString *)dictionaryToJson:(NSDictionary *)dict
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


/**
 将Json字符串装换成字典

 @param jsonString Json字符串
 @return Json字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsError;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsError];
    
    if(jsError) {
        NSLog(@"json解析失败：%@",jsError);
        return nil;
    }
    
    return jsonDict;
}

- (NSString *)encodeBase64String:(NSString * )input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}
- (NSString *)decodeBase64String:(NSString * )input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}
- (NSString *)encodeBase64Data:(NSData *)data
{
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

- (NSString *)decodeBase64Data:(NSData *)data
{
    NSData *bData = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:bData encoding:NSUTF8StringEncoding];
    return base64String;
}

@end
