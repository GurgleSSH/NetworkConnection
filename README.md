# NetworkConnection
### iOS下的网络请求封装

-----

## WHAT 是什么

iOS下的网络请求封装。实现以下功能：

1. 网络状态及可达性检测；
2. 支持GET、POST方式从网络获取JSON数据；
3. 支持JSON对象及JSON字符串的解析；
4. 无网络数据缓存；
5. 统计网络缓存大小；
6. 清除网络缓存；

### 方法

#### ` + sharedNetworkConnection  `

初始化方法（单例），将会创建一个串行的队列用于存放网络请求。

* #### 声明

	```
	+ (instancetype)sharedNetworkConnection
	```
	
* #### 返回值

	返回LSNetworkConnection的实例对象。
	
----

#### ` - (void)getJSONFromURL: HTTPMethod: requestHeader: requestBody: cacheAllowed: stringEncodingSet: complete: `

从网络获取JSON数据并解析或者向网络发送JSON数据。

* #### 声明

	```
	- (void)getJSONFromURL:(NSString *)StringUrl
                HTTPMethod:(LSNetworkHTTPMethod)HTTPMethod
             requestHeader:(NSDictionary *)requestHeader
               requestBody:(NSString *)requestBody
              cacheAllowed:(BOOL)allowCache
         stringEncodingSet:(NSStringEncoding)encodingSet
                  complete:(void(^)(id result, NSData *data))block;
	```

* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| StringUrl | 请求地址 |
	| HTTPMethod | 请求方式（GET/POST） |
	| requestHeader | 请求头 |
	| requestBody | 请求体 |
	| allowCache | 是否允许本地缓存数据 |
	| encodingSet | 编码字符集 |
	| block | 请求完成后执行block |
	
	其中HTTPMethod的参数是LSNetworkHTTPMethod类型的，为枚举值。枚举值及描述如下表。
	
	| 枚举名称 | 描述 | 枚举值 |
	| ------------ | ------------- | ------------ |
	| LSNetworkHTTPMethodGET | GET请求  | 0 |
	| LSNetworkHTTPMethodPOST | POST请求 | 1 |

	
	
----

#### ` - networkIsReachability `

网络是否可达。

* #### 返回值

	返回是否可达的BOOL类型值。

* #### 声明

	```
	- (BOOL)networkIsReachability
	```
	
	
----
	
#### ` - notificationForNetworkReachabilityStatusWithObserver: `

添加观察者来观察网络状态变化。

* #### 声明

	```
	- (void)notificationForNetworkReachabilityStatusWithObserver:(id)observier
	
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| observier | 观察者 |
	

----	

#### ` - (void)networkStatus `

监听网络状态，网络状态改变发送相应通知。

*** 注意！ 必须在AppDelegate调用该方法，才可检查网络可达性。 ***

* #### 声明

	```
	- (void)networkStatus
	
	```
	

----	

#### ` - getByte `

统计缓存大小

* #### 声明

	```
	- (NSUInteger)getByte
	```
	
* #### 返回值

	返回字节大小，单位B。
	
----	


#### ` - clearnCacheWhileComplete: `

清除缓存，当清除完成后执行block块

* #### 声明

	```
	- (void)clearnCacheWhileComplete:(void(^)())block
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| block  | 缓存清除成功后执行block |
	
----	

	
### LSNetworkConnectionNotifications协议

> 当网络可达状态发生变化时，将调用NetworkConnectionNotifications中的协议方法，这些协议方法的回调由通知实现，而不是代理。

#### 协议名称
` LSNetworkConnectionNotifications `

#### 协议方法

##### ` - networkReachabilityStatusUnknown ` *Request*

网络状态未知回调。

* ##### 声明
	
	```
	- (void)networkReachabilityStatusUnknown
	```	
----

##### ` - networkReachabilityStatusNotReachable ` *Request*

网络不可达回调。

* ##### 声明
	
	```
	- (void)networkReachabilityStatusNotReachable
	```	
----

##### ` - networkReachabilityStatusReachableViaWWAN ` *Request*

通过蜂窝网时回调。

* ##### 声明
	
	```
	- (void)networkReachabilityStatusReachableViaWWAN
	```	
----

##### ` - networkReachabilityStatusReachableViaWiFi ` *Request*

通过WiFi时回调。

* ##### 声明
	
	```
	- (void)networkReachabilityStatusReachableViaWiFi
	```	
----



 



 
 
## HOW 如何使用

	





