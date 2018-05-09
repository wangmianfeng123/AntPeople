//
//  AESSecurityUtil.m
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import "AESSecurityUtil.h"
#import "NSString+CJAES.h"
#import "NSData+CJAES.h"
#import "NSDictionary+CJAES.h"

@implementation AESSecurityUtil



/**
 根据call值对请求参数进行加密
 
 @param paramsDict 参数字典
 @param key 密钥
 @return 加密后的参数字典
 */
+ (NSDictionary *)BtDataAESEncrypt:(NSDictionary *)paramsDict keyStr:(NSString *)key
{
    if (paramsDict == nil) {
        return nil;
    }
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:paramsDict];
    NSInteger call = [[paramsDict objectForKey:@"call"] integerValue];
    
    if (call >= 10000) {
//        NSString *jsonString = @"";
//        if ([paramsDict[@"json"] isKindOfClass:[NSString class]]) {
//            jsonString = paramsDict[@"json"];
//        }
         NSString *jsonString = paramsDict[@"json"];
        NSString *aesString = [jsonString AESEncryptStrWithKey:key];
        NSString *urlEncodeStr = [self encodeParameter:aesString];
        urlEncodeStr = [urlEncodeStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        urlEncodeStr = [urlEncodeStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        urlEncodeStr = [urlEncodeStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        [mutDict setValue:urlEncodeStr forKey:@"json"];
        
    }
    
    return mutDict;
}


/**
 解密请求到的密文
 
 @param cryData 密文数据
 @param key 密钥
 @return 解密后的json数据
 */
+ (NSData *)BtDataAESDecrypt:(id)cryData keyStr:(NSString *)key
{
    // 解析数据
    NSString *resJsonStr = [[NSString alloc] initWithData:cryData encoding:NSUTF8StringEncoding];
    
    resJsonStr = [resJsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    resJsonStr = [resJsonStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *dpyString = [resJsonStr AESDecryptStrWithKey:key];
    
    NSData *dpyData = [dpyString dataUsingEncoding:NSUTF8StringEncoding];
    
    return dpyData;
}


// 对参数进行URLEncode处理
+ (NSString *)encodeParameter:(NSString *)originalPara
{
    CFStringRef encodeParaCf = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)originalPara, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    NSString *encodePara = (__bridge NSString *)(encodeParaCf);
    CFRelease(encodeParaCf);
    return encodePara;
}


@end

