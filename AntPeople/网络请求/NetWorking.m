



#import "NetWorking.h"
#import "AFNetworking.h"
#import "BtNetworkManager.h"
#import "LoginViewController.h"

static NetWorking *net = nil;
static AFHTTPSessionManager *manager = nil;

@implementation NetWorking


+ (NetWorking *)shareNet
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        net = [[NetWorking alloc] init];
    });
    return net;
}



-(void)netRequestMethodparameter:(NSDictionary *)params loadStatus:(BOOL)loadStatus remindStatus:(BOOL)remindStatus success:(void (^)(id _Nonnull, BOOL))success failure:(void (^)(NSError * _Nonnull))failure{
    if ([BtNetworkManager shareNetworkManager].netStatus == BtNetworkStatusNone) {
        NSLog(@"网络故障...");
        [SVProgressHUD showErrorWithStatus:@"当前网络异常,请检查网络连接"];
        if (failure) {
            NSError * error = [NSError new];
            failure(error);
        }
        return;
    }
    //参数加密
    NSString * keyString = @"";
    BtAccount * acount = [BtAccountTool account];
    if ([BtAccountTool checkAccount:acount]) {
        keyString = [NSString stringWithFormat:@"%@",stdString(acount.token)];
    }
    NSDictionary * parDict = [AESSecurityUtil BtDataAESEncrypt:params keyStr:keyString];//加密
     NSString *paramString = [NSString stringWithFormat:@"call=%@&json=%@", parDict[@"call"], parDict[@"json"]];
    NSData *textData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [NetWorking requestWithMethod];
    [request setHTTPBody:textData];
    
    if (loadStatus) {
        [SVProgressHUD showWithStatus:@"数据加载中..."];
    }
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
            if (!resDict || jsonError) {
                BtAccount *account = [BtAccountTool account];
                NSString *tokenString = [NSString stringWithFormat:@"%@", account.token];
                // 解密数据
                NSData *jsonData = [AESSecurityUtil BtDataAESDecrypt:responseObject keyStr:tokenString];
                if (jsonData) {
                    NSDictionary *decDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    resDict = decDict;
                }
            }
            NSHTTPURLResponse * urlResp = (NSHTTPURLResponse *)response;
            NSDictionary * headerDict = urlResp.allHeaderFields;
            if (headerDict) {
                NSString * cookieStr = headerDict[@"Set-Cookie"];
                if ([cookieStr isKindOfClass:[NSString class]]) {
                    [kUserDefaults setObject:cookieStr forKey:@"Set-Cookie"];
                    [kUserDefaults synchronize];
                }
            }
            
            NSString *resState = [NSString stringWithFormat:@"%@", resDict[@"state"]];
            if ([resState isEqualToString:@"0"]) {//状态返回0
                NSString * remindStr = [NSString stringWithFormat:@"%@",resDict[@"errorMsg"]];
                if (remindStatus) {
                    [SVProgressHUD showErrorWithStatus:remindStr];
                }
                
                NSString *errorCode = [NSString stringWithFormat:@"%@", resDict[@"errorCode"]];
                if ([errorCode isEqualToString:@"102"] || [errorCode isEqualToString:@"103"] || [errorCode isEqualToString:@"204"]) {
                    // 静默登录
                    [BtAccount silenceLoginAntPeople];
                } else if ([errorCode isEqualToString:@"40106"]) {
                    // 退到登录页面
                    LoginViewController *loginVC = [[LoginViewController alloc] init];
                    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
                }
                if (success) {
                    success(resDict,NO);
                }
            }else if ([resState isEqualToString:@"1"]){
                if (success) {
                    success(resDict,YES);
                }
            }
            

        } else {
            [SVProgressHUD dismiss];
            if (failure) {
                failure(error);
            }
        }
    }] resume];
}



//post请求
- (void)PostWithURL:(NSString *)urlString parameters:(NSDictionary *)parameters success:(successBlock)success fail:(failureBlock)fail
{
    //致空请求
    if (manager) {
        manager = nil;
    }
    manager = [AFHTTPSessionManager manager];
    AFJSONResponseSerializer *sr = [AFJSONResponseSerializer serializer];
    sr.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    manager.requestSerializer.timeoutInterval = 10.f;

    manager.responseSerializer = sr;
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        NSHTTPURLResponse * urlResp = (NSHTTPURLResponse *)task.response;
        NSDictionary * headerDict = urlResp.allHeaderFields;
        NSLog(@"cookie:%@",headerDict);
        NSString * cookieStr = headerDict[@"Set-Cookie"];
        if ([cookieStr isKindOfClass:[NSString class]]) {
            [kUserDefaults setObject:cookieStr forKey:@"Set-Cookie"];
            [kUserDefaults synchronize];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}


// 请求数据
- (void)netRequestParameter:(nullable NSDictionary *)params success:(void(^_Nonnull)(id _Nonnull json))success failure:(void(^_Nonnull)(NSError * _Nonnull error))failure
{
    NSString *paramString = [NSString stringWithFormat:@"call=%@&json=%@", params[@"call"], params[@"json"]];
    NSData *textData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [NetWorking requestWithMethod];
    [request setHTTPBody:textData];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonError];
            if (!resDict || jsonError) {
                BtAccount *account = [BtAccountTool account];
                NSString *tokenString = [NSString stringWithFormat:@"%@", account.token];
                // 解密数据
                NSData *jsonData = [AESSecurityUtil BtDataAESDecrypt:responseObject keyStr:tokenString];
                if (jsonData) {
                    NSDictionary *decDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    resDict = decDict;
                }
            }
            NSString *resState = [NSString stringWithFormat:@"%@", resDict[@"state"]];
            if ([resState isEqualToString:@"0"]) {
                NSString *errorCode = [NSString stringWithFormat:@"%@", resDict[@"errorCode"]];
                NSString *errorMsg = stdString(resDict[@"errorMsg"]);
                if ([errorCode isEqualToString:@"102"] || [errorCode isEqualToString:@"103"] || [errorCode isEqualToString:@"204"]) {
                    if (errorMsg.length > 0) {
                        [SVProgressHUD showErrorWithStatus:errorMsg];//展示错误信息
                    }
                    // 静默登录
                    [BtAccount silenceLoginAntPeople];
                } else if ([errorCode isEqualToString:@"40106"]) {
                    if (errorMsg.length > 0) {
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                    }
                    // 退到登录页面
                    LoginViewController *loginVC = [[LoginViewController alloc] init];
                    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
                }
            }
            if (success) {
                NSHTTPURLResponse * urlResp = (NSHTTPURLResponse *)response;
                NSDictionary * headerDict = urlResp.allHeaderFields;
                NSLog(@"cookdddd:%@",headerDict);
                NSString * cookieStr = headerDict[@"Set-Cookie"];
                if ([cookieStr isKindOfClass:[NSString class]]) {
                    [kUserDefaults setObject:cookieStr forKey:@"Set-Cookie"];
                    [kUserDefaults synchronize];
                }
                success(resDict);
            }
        } else {
            [SVProgressHUD dismiss];
            if (failure) {
                failure(error);
                [SVProgressHUD showErrorWithStatus:@"当前网络异常，请检查网络连接"];
            }
        }
    }] resume];
}






//post请求,上传cookie
- (void)PostWithURLwithCookie:(NSString *)urlString parameters:(NSDictionary *)parameters success:(successBlock)success fail:(failureBlock)fail{
    if (manager) {
        manager = nil;
    }
    manager = [AFHTTPSessionManager manager];
    AFJSONResponseSerializer *sr = [AFJSONResponseSerializer serializer];
    sr.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    manager.requestSerializer.timeoutInterval = 10.f;
    manager.responseSerializer = sr;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString * cookieStr = [kUserDefaults objectForKey:@"Set-Cookie"];
    
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:cookieStr forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}



// 创建NSURLRequest
+ (NSMutableURLRequest *)requestWithMethod
{
    NSString *reqMethodString = @"POST";
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:reqMethodString URLString:SERVER_KEY parameters:nil error:nil];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *CookieStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"Set-Cookie"];
    if (![CookieStr isKindOfClass:[NSString class]]) {
        CookieStr = @"";
    }
    NSLog(@"********%@",CookieStr);
    [request setValue:CookieStr forHTTPHeaderField:@"Cookie"];
    
    return request;
}


- (void)GetWithUrl:(NSString *)url success:(successBlock)success failure:(failureBlock)fail {
    //致空请求
    if (manager) {
        manager = nil;
    }
    manager = [AFHTTPSessionManager manager];
    AFJSONResponseSerializer *sr = [AFJSONResponseSerializer serializer];
    sr.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    manager.requestSerializer.timeoutInterval = 10.f;
    manager.responseSerializer = sr;
    
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         fail(error);
    }];
    
}
//取消网络请求
- (void)cancelNetWork
{
    if (manager) {
        
        [manager.operationQueue cancelAllOperations];
    }
}




#pragma mark - 生成json格式的文本
+ (NSString *)returnJson:(id)params
{
    NSString *jsonString = @"";
    NSError *jsonError = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:params
                                                      options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonData && !jsonError) {
        jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    
    return jsonString;
}



#pragma mark - 上传图片  表单上传
static NSString *separateStr = @"--";
static NSString *boundaryStr = @"antPeople";
static NSString *uploadID = @"file";


// 上传图片文件
+ (void)btUploadImageWithParams:(nullable NSDictionary *)params image:(nonnull id)image loadStatus:(BOOL)loadStatus success:(void(^_Nonnull)(NSDictionary *_Nonnull result, BOOL status))success failure:(void(^_Nonnull)(NSError *_Nullable error))failure
{
    // 上传的数据
    NSData *uploadData;
    if ([image isKindOfClass:[UIImage class]]) {
        uploadData = UIImageJPEGRepresentation(image, 1.f);
    } else if ([image isKindOfClass:[NSData class]]) {
        uploadData = image;
    }
    NSMutableData *dataBody = [NSMutableData data];
    [dataBody appendData:[self parameterWithDict:params]];
    if ([uploadData length] != 0) {
        [dataBody appendData:[self fileData:uploadData mimeType:@"image/jpeg/jpg/png" uploadFile:[self uploadImageFileName]]];
    }
    [dataBody appendData:[self suffixOfUpload]];
    NSMutableURLRequest *request = [self uploadRequestWithData:dataBody];
    if (loadStatus) {
        [SVProgressHUD showWithStatus:@"数据上传中..."];
    }
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *result = [NSString stringWithFormat:@"%@", resDict[@"state"]];
            NSLog(@"response Data : %@", resDict);
            if ([result isEqualToString:@"0"]) {
                NSString *remindStr = [NSString stringWithFormat:@"%@", resDict[@"errorMsg"]];
                [SVProgressHUD showErrorWithStatus:remindStr];
                NSLog(@"errorMsg %@", remindStr);
                if (success) {
                    success(resDict, NO);
                }
            } else if ([result isEqualToString:@"1"]){
                if (success) {
                    success(resDict, YES);
                }
            }
        } else {
            [SVProgressHUD dismiss];
            if (failure) {
                failure(error);
            }
        }
    }] resume];
}




/**
 非文件参数
 
 @param parameter 参数列表 [字典]
 @return 参数数据
 */
+ (NSData *)parameterWithDict:(NSDictionary *_Nullable)parameter
{
    if ([parameter isKindOfClass:[NSDictionary class]]) {
        NSArray *keysArr = [parameter allKeys];
        NSMutableString *strM = [NSMutableString string];
        
        for (NSString *keyStr in keysArr) {
            [strM appendFormat:@"%@%@\r\n", separateStr, boundaryStr];
            [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", keyStr];
            [strM appendString:@"\r\n"];
            [strM appendFormat:@"%@", parameter[keyStr]];
            [strM appendString:@"\r\n"];
        }
        return [self dataEncode:strM];
    }
    return [NSData data];
}



// 获取随机文件名
+ (NSString *)uploadImageFileName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%d_%@.png", arc4random(), str];
    NSLog(@"upload image fileName %@", fileName);
    
    return fileName;
}




/**
 创建数据上传的NSURLRequest
 
 @param bodyData 文件数据
 @return NSURLRequest
 */
+ (NSMutableURLRequest *_Nonnull)uploadRequestWithData:(NSData *_Nonnull)bodyData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BtHostFileUrl] cachePolicy:0 timeoutInterval:30.0f];
    [request setHTTPMethod:@"POST"];
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    NSString *CookieStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"btCookie"];
    if (![CookieStr isKindOfClass:[NSString class]]) {
        CookieStr = @"";
    }
    [request setValue:CookieStr forHTTPHeaderField:@"Cookie"];
    NSUInteger len = bodyData.length;
    NSString *strLen = [NSString stringWithFormat:@"%lu",(unsigned long)len];
    [request addValue:strLen forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:bodyData];
    
    return request;
}




/**
 文件参数
 
 @param file 文件数据 data
 @param mimeType mimeType
 @param fileName 文件名
 @return 数据
 */
+ (NSData *_Nonnull)fileData:(NSData *_Nonnull)file mimeType:(NSString *_Nonnull)mimeType uploadFile:(NSString *_Nonnull)fileName
{
    NSMutableData *body = [NSMutableData data];
    [body appendData:[self dataEncode:[NSString stringWithFormat:@"%@%@\r\n", separateStr, boundaryStr]]];
    [body appendData:[self dataEncode:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadID, fileName]]];
    [body appendData:[self dataEncode:[NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType]]];
    
    [body appendData:[self dataEncode:@"\r\n"]];
    [body appendData:file];// 文件
    [body appendData:[self dataEncode:@"\r\n"]];
    
    return body;
}



/**
 结尾标识
 @return 结尾标识
 */
+ (NSData *)suffixOfUpload
{
    return [self dataEncode:[NSString stringWithFormat:@"%@%@%@\r\n", separateStr, boundaryStr, separateStr]];
}

+ (NSData *)dataEncode:(NSString *)str
{
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}




@end
