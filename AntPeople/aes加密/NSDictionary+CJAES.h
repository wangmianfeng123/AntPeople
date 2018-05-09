//
//  NSDictionary+CJAES.h
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CJAES)

/**
 加密
 
 @param keyStr 密钥
 @return 加密结果
 */
- (NSString *)AESEncrypt:(NSDictionary *)plainDict withKey:(NSString *)keyStr;


/**
 解密专换成字典
 
 @param keyStr 密钥
 @return 解密结果
 */
- (NSDictionary *)AESDecrypt:(NSString *)base64Str withKey:(NSString *)keyStr;



@end
