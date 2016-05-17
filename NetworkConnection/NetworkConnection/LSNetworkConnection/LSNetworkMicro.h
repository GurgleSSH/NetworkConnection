//
//  LSNetworkMicro.h
//  NetworkConnection
//
//  Created by liushuai on 16/5/17.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#ifndef LSNetworkMicro_h
#define LSNetworkMicro_h

//缓存沙盒路径
#define LSNetworkConnectionCacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

//对象是否能够响应方法
#define RESPONDS_TO(who, method) if ([who respondsToSelector:@selector(method)])

//对象是否能够响应方法（含参）
#define RESPONDS_TO_WITH(who, method, param) if ([who respondsToSelector:@selector(method param)])


#endif /* LSNetworkMicro_h */
