//
//  NSString+LSMD5.m
//
//  Created by liushuai on 16/3/30.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import "NSString+LSMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LSMD5)

/**
 *  @author liushuai1992@gmail.com, 2016-03
 *
 *  @brief 将给定的字符串进行MD5加密
 *
 *  @param inputStr 给定的字符串
 *
 *  @return 经过MD5加密后的字符串
 */
+ (NSString *)md5:(NSString *)inputStr {
    const char *cStr = [inputStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [str appendFormat:@"%02X", result[i]];
    }
    return str;
}



@end
