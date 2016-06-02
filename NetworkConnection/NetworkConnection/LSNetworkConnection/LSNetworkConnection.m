//
//  LSNetworkConnection.m
//  NetworkConnection
//
//  Created by liushuai on 16/5/17.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import "LSNetworkConnection.h"
#import "LSNetworkReachabilityManager.h"
#import "NSString+LSMD5.h"
#import "LSNetworkMicro.h"

NSString * const LSNetworkReachabilityStatusUnknownNotification = @"LSNetworkReachabilityStatusUnknownNotification";
NSString * const LSNetworkReachabilityStatusNotReachableNotification = @"LSNetworkReachabilityStatusNotReachableNotification";
NSString * const LSNetworkReachabilityStatusReachableViaWWANNotification = @"LSNetworkReachabilityStatusReachableViaWWANNotification";
NSString * const LSNetworkReachabilityStatusReachableViaWiFiNotification = @"LSNetworkReachabilityStatusReachableViaWiFiNotification";

@interface LSNetworkConnection ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation LSNetworkConnection {
    NSFileManager *_fileManager;
}

#pragma mark - dealloc
- (void)dealloc
{
}

#pragma mark - init
+ (instancetype)sharedNetworkConnection {
    static LSNetworkConnection *networkConnection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkConnection = [[LSNetworkConnection alloc] init];
        [networkConnection networkStatus];
        if (!networkConnection.queue) {
            networkConnection.queue = dispatch_queue_create("com.liushuai.lsnetworkconnection", DISPATCH_QUEUE_SERIAL);
        }
    });
    return networkConnection;
}

#pragma mark - data parser
- (void)getJSONFromURL:(NSString *)StringUrl HTTPMethod:(LSNetworkHTTPMethod)HTTPMethod requestHeader:(NSDictionary *)requestHeader requestBody:(NSString *)requestBody cacheAllowed:(BOOL)allowCache stringEncodingSet:(NSStringEncoding)encodingSet complete:(void(^)(id result, NSData *data))block {
    //预处理url字符串
    NSString *urlStr = [self preprocessURLString:StringUrl];
    //network is reachability? 网络可达否？
    if ([self networkIsReachability]) {
        NSLog(@"可达");
        //网络可达准备从网络请求数据
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //设置请求类型
        if (HTTPMethod == 0) request.HTTPMethod = @"GET";
        if (HTTPMethod == 1) request.HTTPMethod = @"POST";
        //设置请求头
        if (requestHeader) {
            NSArray *arr = [requestHeader allKeys];
            for (NSString *str in arr) {
                [request setValue:[requestHeader valueForKey:str] forHTTPHeaderField:str];
            }
        }
        //设置请求体
        if (requestBody) {
            request.HTTPBody = [requestBody dataUsingEncoding:encodingSet];
        }
        NSURLSession *session = [NSURLSession sharedSession];
        //在子线程请求数据
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            //return main thread 返回主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                //analysis data 分析数据
                if (httpResponse.statusCode == 200) {
                    NSData *jsonData = [NSData data];
                    id result;
                    NSError *error = nil;
                    NSString * str = [[NSString alloc] initWithData:data encoding: encodingSet];
                    //adjust json string 判断是json对象还是json字符串
                    if ([str hasPrefix:@"\""]) {
                        //is json string 是json字符串
                        jsonData = [str dataUsingEncoding:encodingSet];
                        result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
                    } else {
                        //is json objest 是json对象
                        jsonData = data;
                        result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                    }
                    block(result, jsonData);
                    //是否允许缓存
                    if (allowCache) {
                        [[LSNetworkConnection sharedNetworkConnection] helperNSDataWriteToDisk:jsonData fileName:[NSString md5:StringUrl]];
                    }
                }
            });
        }];
        [dataTask resume];
    } else {
        NSLog(@"不可达");
        //network is not reachability 网络不可达，判断是否允许从本地读取缓存
        if (allowCache) {
            //allow read cache from local 允许缓存，则从本地读取缓存
            NSData *data = [[LSNetworkConnection sharedNetworkConnection] helperNSDataReadFromDiskFileName:[NSString md5:StringUrl]];
            if (data) {
                NSError *error = nil;
                id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                block(result, data);
            }
        }
    }
}

#pragma mark - network reachability
- (BOOL)networkIsReachability {
    return [LSNetworkReachabilityManager sharedManager].isReachable;
}

- (void)notificationForNetworkReachabilityStatusWithObserver:(id)observier {
    RESPONDS_TO(observier, networkReachabilityStatusUnknown) {
        [[NSNotificationCenter defaultCenter] addObserver:observier selector:@selector(networkReachabilityStatusUnknown) name:LSNetworkReachabilityStatusUnknownNotification object:nil];
    }
    RESPONDS_TO(observier, networkReachabilityStatusNotReachable) {
        [[NSNotificationCenter defaultCenter] addObserver:observier selector:@selector(networkReachabilityStatusNotReachable) name:LSNetworkReachabilityStatusNotReachableNotification object:nil];
    }
    RESPONDS_TO(observier, networkReachabilityStatusReachableViaWWAN) {
        [[NSNotificationCenter defaultCenter] addObserver:observier selector:@selector(networkReachabilityStatusReachableViaWWAN) name:LSNetworkReachabilityStatusReachableViaWWANNotification object:nil];
    }
    RESPONDS_TO(observier, networkReachabilityStatusReachableViaWiFi) {
        [[NSNotificationCenter defaultCenter] addObserver:observier selector:@selector(networkReachabilityStatusReachableViaWiFi) name:LSNetworkReachabilityStatusReachableViaWiFiNotification object:nil];
    }
}

//AppDelegate应调用该方法
- (void)networkStatus {
    [[LSNetworkReachabilityManager sharedManager] startMonitoring];
    [[LSNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(LSNetworkReachabilityStatus status) {
        switch (status) {
            case LSNetworkReachabilityStatusUnknown:
            {
                //NSLog(@"LSNetworkReachabilityStatusUnknown");
                [[NSNotificationCenter defaultCenter] postNotificationName:LSNetworkReachabilityStatusUnknownNotification object:nil];
                break;
            }
                
            case LSNetworkReachabilityStatusNotReachable:
            {
                //NSLog(@"LSNetworkReachabilityStatusNotReachable");
                [[NSNotificationCenter defaultCenter] postNotificationName:LSNetworkReachabilityStatusNotReachableNotification object:nil];
                break;
            }
                
            case LSNetworkReachabilityStatusReachableViaWWAN:
            {
                //NSLog(@"LSNetworkReachabilityStatusReachableViaWWAN");
                [[NSNotificationCenter defaultCenter] postNotificationName:LSNetworkReachabilityStatusReachableViaWWANNotification object:nil];
                break;
            }
            case LSNetworkReachabilityStatusReachableViaWiFi:
            {
                //NSLog(@"LSNetworkReachabilityStatusReachableViaWiFi");
                [[NSNotificationCenter defaultCenter] postNotificationName:LSNetworkReachabilityStatusReachableViaWiFiNotification object:nil];
                break;
            }
            default:
            {
                //NSLog(@"default");
                break;
            }
        }
    }];
}

#pragma mark - helper
/**
 *  @brief url字符串预处理
 *
 *  @param urlStr url字符串
 *
 *  @return 处理后的符合url查询字符集的url字符串
 */
- (NSString *)preprocessURLString:(NSString *)urlStr {
    //remove whitespace character 移除空白字符
    urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //encoding string with URLQuery AllowedCharacters 转换为url查询字符集
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return urlStr;
}

/**
 *  @author liushuai1992@gmail.com, 2016-04
 *
 *  @brief 将NSData对象写入本地
 *
 *  @param data     要写入的NSData对象
 *  @param fileName 要写入本地的文件名
 *
 *  @return 写入本地成功否？
 */
- (BOOL)helperNSDataWriteToDisk:(NSData *)data fileName:(NSString *)fileName {
    //appending path
    NSString *path = [LSNetworkConnectionCacheDirectory stringByAppendingPathComponent:fileName];
    NSLog(@"%@", path);
    //write file
    return [data writeToFile:path atomically:YES];
}


/**
 *  @author liushuai1992@gmail.com, 2016-04
 *
 *  @brief 根据给定文件名从本地读取文件
 *
 *  @param fileName 给定的文件名
 *
 *  @return 从本地读取到的NSData对象
 */
- (NSData *)helperNSDataReadFromDiskFileName:(NSString *)fileName {
    //appending path
    NSString *path = [LSNetworkConnectionCacheDirectory stringByAppendingPathComponent:fileName];
    NSLog(@"%@", path);
    //read file
    return [NSData dataWithContentsOfFile:path];
}

/**
 *  @author liushuai1992@gmail.com, 2016-04
 *
 *  @brief 统计缓存大小
 *
 *  @return 缓存字节数
 */
- (NSUInteger)getByte {
    __block NSUInteger size = 0;
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    dispatch_sync(_queue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:LSNetworkConnectionCacheDirectory];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [LSNetworkConnectionCacheDirectory stringByAppendingPathComponent:fileName];
            NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [dic fileSize];
        }
        
    });
    return size;
}


/**
 *  @author liushuai1992@gmail.com, 2016-04
 *
 *  @brief clearn cache and run block code 清除缓存，当清除完成后执行block块
 *
 *  @param block 缓存清除成功后执行
 */
- (void)clearnCacheWhileComplete:(void(^)())block{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    dispatch_async(_queue, ^{
        //删除指定文件夹及其内容
        [_fileManager removeItemAtPath:LSNetworkConnectionCacheDirectory error:nil];
        //重新创建文件夹
        [_fileManager createDirectoryAtPath:LSNetworkConnectionCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        //返回主线程执行block
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}



@end
