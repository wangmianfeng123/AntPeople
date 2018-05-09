//
//  generationOrder.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/27.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "generationOrder.h"

@implementation generationOrder


+(void)categoryNameDic:(NSDictionary *)categoryName categoryNameBlock:(void (^)(NSArray *, NSArray *, BOOL))categoryBlock failue:(void (^)(NSError *))failue{
    [[NetWorking shareNet]netRequestMethodparameter:categoryName loadStatus:NO remindStatus:NO success:^(id  _Nonnull json, BOOL status) {
        if (categoryBlock) {
            NSMutableArray * nameMarr = [[NSMutableArray alloc] init];
            NSDictionary * dic = json[@"info"];
            
            for (NSDictionary * dict in dic) {
                if (dict[@"type_name"]) {
                    [nameMarr addObject:dict[@"type_name"]];
                }
            }
            
            NSMutableArray * categoryArr = [[NSMutableArray alloc] init];
            for (NSDictionary * dict1 in dic) {
                NSArray * arr = dict1[@"list"];
                for (NSDictionary * dict2 in arr) {
                    if (![categoryArr containsObject:dict2[@"category_id"]]) {
                        [categoryArr addObject:dict2[@"category_id"]];
                    }
                }
            }
            categoryBlock(nameMarr,categoryArr,status);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failue) {
            failue(error);
        }
    }];
}



+(void)BindAendUser:(NSDictionary *)Auser success:(void (^)(NSArray *, BOOL))success failue:(void (^)(NSError *))failue{
    [[NetWorking shareNet] netRequestMethodparameter:Auser loadStatus:NO remindStatus:NO success:^(id  _Nonnull json, BOOL status) {
        
        if (success) {
            NSMutableArray * mDict = [[NSMutableArray alloc] init];
             NSDictionary * dict = (NSDictionary *)json;
           NSArray * arr = dict[@"info"];
            [mDict addObjectsFromArray:[myTeamModel mj_objectArrayWithKeyValuesArray:arr]];
            NSLog(@"获取a端的用户列表:%@",mDict);
            success(mDict,status);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failue) {
            failue(error);
        }
    }];
}




+(void)getCountryLelve:(NSDictionary *)country success:(void (^)(NSArray *, BOOL))success failue:(void (^)(NSError *))failue{
    [[NetWorking shareNet] netRequestMethodparameter:country loadStatus:NO remindStatus:NO success:^(id  _Nonnull json, BOOL status) {
        if (success) {
            NSLog(@"获取行政区划列表:%@",json);
            
            NSMutableArray * mDict = [[NSMutableArray alloc] init];
            NSDictionary * dict = (NSDictionary *)json;
            NSArray * arr = dict[@"info"];
            [mDict addObjectsFromArray:arr];
            success(mDict,status);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failue) {
            failue(error);
        }
    }];
}






@end
