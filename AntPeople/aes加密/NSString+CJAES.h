//
//  NSString+CJAES.h
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CJAES)


/**
 加密 [字符串加密]
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSString *)AESEncryptStrWithKey:(NSString *)keyStr;


/**
 解密
 
 @param keyStr 密钥
 @return 解密结果
 */
- (NSString *)AESDecryptStrWithKey:(NSString *)keyStr;


/**
 加密 [Json字符串加密]
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSString *)AESEncryptJsonStrWithKey:(NSString *)keyStr;

@end
