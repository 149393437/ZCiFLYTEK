//
//  RecognizerFactory.h
//  MSCDemo
//
//  Created by iflytek on 13-6-9.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecognizerFactory : NSObject
/*
 * @ 创建识别对象
   <Param name=delegate> object which implement IFlySpeechRecognizerDelegate</Param>
   <Param name=domain> domain:iat,search,video,poi,music,asr;iat,普通文本听写; search,热词搜索;video,视频音乐搜索;asr: 关键词识别;</Param>
 */
+(id) CreateRecognizer:(id)delegate Domain:(NSString*) domain;
@end
