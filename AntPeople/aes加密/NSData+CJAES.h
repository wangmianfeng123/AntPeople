//
//  NSData+CJAES.h
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CJAES)


/**
 加密
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSData *)AESEncryptWithKey:(NSString *)keyStr;


/**
 解密
 
 @param keyStr 密钥
 @return 解密结果
 */
- (NSData *)AESDecryptWithKey:(NSString *)keyStr;


@end
