//
//  LSNetworkConnection.h
//  NetworkConnection
//
//  Created by liushuai on 16/5/17.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LSNetworkHTTPMethod) {
    LSNetworkHTTPMethodGET  = 0,
    LSNetworkHTTPMethodPOST = 1
};

/**
 *  @brief 当网络可达状态发生变化时，将调用NetworkConnectionNotifications中的协议方法，这些协议方法的回调由通知实现，而不是代理。
 */
@protocol LSNetworkConnectionNotifications <NSObject>

- (void)networkReachabilityStatusUnknown;           //网络状态未知
- (void)networkReachabilityStatusNotReachable;      //网络不可达
- (void)networkReachabilityStatusReachableViaWWAN;  //通过蜂窝网
- (void)networkReachabilityStatusReachableViaWiFi;  //通过WiFi

@end


@interface LSNetworkConnection : NSObject
/**
*  @brief 初始化方法(单例模式)
*
*  @return NetworkConnection实例
*/
+ (instancetype)sharedNetworkConnection;

/**
 *  @brief 从网络获取JSON数据
 *
 *  @param StringUrl     请求地址
 *  @param HTTPMethod    请求方式（GET/POST）
 *  @param requestHeader 请求头
 *  @param requestBody   请求体
 *  @param allowCache    是否允许本地缓存数据
 *  @param encodingSet   编码字符集
 *  @param block         请求完成后执行block
 */
- (void)getJSONFromURL:(NSString *)StringUrl
            HTTPMethod:(LSNetworkHTTPMethod)HTTPMethod
         requestHeader:(NSDictionary *)requestHeader
           requestBody:(NSString *)requestBody
          cacheAllowed:(BOOL)allowCache
     stringEncodingSet:(NSStringEncoding)encodingSet
              complete:(void(^)(id result, NSData *data))block;

/**
 *  @brief 网络是否可达
 *
 *  @return 网络可达否？
 */
- (BOOL)networkIsReachability;

/**
 *  @brief 添加观察者来观察网络状态变化
 *
 *  @param observier 观察者
 */
- (void)notificationForNetworkReachabilityStatusWithObserver:(id)observier;

/**
 *  @brief 监听网络状态，网络状态改变发送相应通知。应在AppDelegate调用该方法
 */
- (void)networkStatus;

/**
 *  @brief 统计缓存大小
 *
 *  @return 缓存字节数
 */
- (NSUInteger)getByte;


/**
 *
 *  @brief 清除缓存，当清除完成后执行block块
 *
 *  @param block 缓存清除成功后执行block
 */
- (void)clearnCacheWhileComplete:(void(^)())block;



@end
