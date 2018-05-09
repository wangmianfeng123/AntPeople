//
//  networkService.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2017/11/15.
//  Copyright © 2017年 王绵峰. All rights reserved.
//


#ifndef network_h

#define network_h

//推送测试地址
//#define SERVER_KEY @"https://192.168.1.131/api"
//#define SERVER_KEY    @"https://192.168.1.131/api"//伟领

//#define SERVER_KEY    @"http://192.168.1.105:9080/api"//志坤




#define SERVER_KEY   @"http://192.168.1.100:9080/api"//鹏冲
////#define SERVER_KEY     @"https://test.52bnt.com/api"

#define BtHostFileUrl  @"http://192.168.1.105:9080/api?"
#define SHARE_KEY      @"http://192.168.1.105:9080/shareReg.html"



// ----  ------
//#define TestRelease 0   // default 1
////分享地址
//#ifdef DEBUG
//    //测试服务器
//    #define SERVER_KEY     @"https://test.52bnt.com/api"
//    #define BtHostFileUrl  @"https://test.52bnt.com/file"
//    #define SHARE_KEY      @"https://test.52bnt.com/shareReg.html"
//
//#else
//    #if TestRelease
//        //正式服务器地址
//        #define SHARE_KEY      @"https://www.52bnt.com/shareReg.html"
//        #define BtHostFileUrl  @"https://www.52bnt.com/file"
//        #define SERVER_KEY      @"https://www.52bnt.com/api"
//    #else
//        //测试服务器
//        #define SHARE_KEY      @"https://test.52bnt.com/shareReg.html"
//        #define   SERVER_KEY   @"https://test.52bnt.com/api"
//        #define BtHostFileUrl  @"https://test.52bnt.com/file"
//
//    #endif
//#endif
//
//#define   URL_MACRO(p) [NSString stringWithFormat:@"%@%@",SERVER_KEY,p]

#endif /* network_h */


