//
//  AESSecurityUtil.h
//  AESDemo
//
//  Created by Jonathan on 2017/11/10.
//  Copyright © 2017年 Circus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESSecurityUtil : NSObject



/**
 根据call值对请求参数进行加密

 @param paramsDict 参数字典
 @param key 密钥
 @return 加密后的参数字典
 */
+ (NSDictionary *)BtDataAESEncrypt:(NSDictionary *)paramsDict keyStr:(NSString *)key;



/**
 解密请求到的密文

 @param cryData 密文数据
 @param key 密钥
 @return 解密后的json数据
 */
+ (NSData *)BtDataAESDecrypt:(id)cryData keyStr:(NSString *)key;





@end
