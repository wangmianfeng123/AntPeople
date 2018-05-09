//
//  GJJBlockDefines.h
//  MyTool
//
//  Created by Wong on 2017/11/3.
//  Copyright © 2017年 com.wong.t.c.h. All rights reserved.
//

#ifndef GJJBlockDefines_h
#define GJJBlockDefines_h
#import <UIKit/UIKit.h>

typedef void (^GJJBlock) (void);
typedef void (^GJJBoolBlock) (BOOL);
typedef void (^GJJBlockBlock) (GJJBlock block);
typedef void (^GJJBlockBoolBlock) (GJJBoolBlock block);
typedef void (^GJJIntegerBlock) (NSInteger iVal);
typedef void (^GJJFloatBlock) (float fVal);
typedef void (^GJJDoubleBlock) (double dVal);
typedef void (^GJJStringBlock) (NSString *str);
typedef void (^GJJDicBlock) (NSDictionary *dic);
typedef void (^GJJArryBlock) (NSArray *ary);
typedef void (^GJJObjectBlock) (id obj);
typedef void (^GJJErrorBlock) (NSError *err);
typedef void (^GJJIndexPathBlock) (NSIndexPath * path);
typedef void (^GJJCoordinateBlock) (double lat, double lng);
typedef void (^GJJStructBlock) (CGPoint point);
typedef void (^GJJBlockObjectBlock) (GJJObjectBlock objectBlock);
typedef void (^GJJObjectAndIntegerBlock) (id obj,NSInteger iVal);
typedef void (^GJJObjectAndIDicBlock) (id obj,NSDictionary *dic);











#endif /* GJJBlockDefines_h */
