

#import <Foundation/Foundation.h>




typedef void (^successBlock) (NSDictionary *dataDict);
typedef void (^failureBlock) (NSError *error);

@interface NetWorking : NSObject
//网络请求，单利
+ (NetWorking *)shareNet;

//post 临时（不拼接接口）
- (void)PostWithURL:(NSString *)urlString parameters:(NSDictionary *)parameters success:(successBlock)success fail:(failureBlock)fail;



- (void)PostWithURLwithCookie:(NSString *)urlString parameters:(NSDictionary *)parameters success:(successBlock)success fail:(failureBlock)fail;



//get
- (void)GetWithUrl:(NSString *)url success:(successBlock)dataBlock failure:(failureBlock)failureBlock;

// 创建NSURLRequest
+ (NSMutableURLRequest *)requestWithMethod;

//转化为json字符串
+ (NSString *)returnJson:(id)params;


// 对参数进行URLEncode处理
+ (NSString *)encodeParameter:(NSString *)originalPara;

/**
 请求数据
 @param params 参数
 @param success 成功
 @param failure 失败
 */
- (void)netRequestParameter:(nullable NSDictionary *)params success:(void(^_Nonnull)(id _Nonnull json))success failure:(void(^_Nonnull)(NSError * _Nonnull error))failure;



/**
 请求数据
 
 @param params 参数
 @param loadStatus 是否显示加载动画
 @param remindStatus 是否显示错误信息
 @param success 成功
 @param failure 失败
 */
- (void)netRequestMethodparameter:(nullable NSDictionary *)params loadStatus:(BOOL)loadStatus remindStatus:(BOOL)remindStatus success:(void(^_Nonnull)(id _Nonnull json, BOOL status))success failure:(void(^_Nonnull)(NSError * _Nonnull error))failure;



/**
 上传图片文件
 
 @param params 参数
 @param image 图片数据 [UIImage || NSData]
 @param success 成功结果
 @param failure 失败结果
 */
+ (void)btUploadImageWithParams:(nullable NSDictionary *)params image:(nonnull id)image loadStatus:(BOOL)loadStatus success:(void(^_Nonnull)(NSDictionary *_Nonnull result, BOOL status))success failure:(void(^_Nonnull)(NSError *_Nullable error))failure;



@end
