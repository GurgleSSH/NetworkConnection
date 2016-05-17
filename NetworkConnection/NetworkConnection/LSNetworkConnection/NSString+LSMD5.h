//
//  NSString+LSMD5.h
//  Trade
//
//  Created by liushuai on 16/3/30.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LSMD5)

/**
 *  @author liushuai1992@gmail.com, 2016-03
 *
 *  @brief 将给定的字符串进行MD5加密
 *
 *  @param inputStr 给定的字符串
 *
 *  @return 经过MD5加密后的字符串
 */
+ (NSString *)md5:(NSString *)inputStr;

@end
