//
//  ZCiFLYTEK.h
//  Xunfei_demo_1401
//
//  Created by ZhangCheng on 14-4-19.
//  Copyright (c) 2014年 zhangcheng. All rights reserved.
//版本说明 iOS研究院 305044955
//zc封装语音识别1.0版本
/*
 需要添加系统的库
 AdSupport
 AddressBook
 QuartzCore
 SystemCOnfiguration
 AudioToolBox
 libz
 讯飞提供的库
 iflyMSC.frameWork
 
 代码示例
 //读取
 ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
 [xunfei playStart:@"我是最帅的"];

 
 //识别
 ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
 [xunfei discernBlock:^(NSString *a) {
 NSLog(@"识别出来的结果~%@",a);
 }];
 */

#import <Foundation/Foundation.h>
//读取
#import "iflyMSC/IFlySynthesizerViewDelegate.h"
#import "iflyMSC/IFlySynthesizerView.h"
//识别

#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"
@interface ZCiFLYTEK : NSObject
<IFlySynthesizerViewDelegate,IFlyRecognizerViewDelegate>
{
    
    IFlySynthesizerView* iFlySynthesizerView;//播放使用
    
    IFlyRecognizerView*iFlyRecognizerView;//识别
    
}

@property(nonatomic,copy)void(^onResult)(NSString*);
//获得指针的单例
+(id)shareManager;
//识别
-(void)discernBlock:(void(^)(NSString*))a;
//读取
-(void)playStart:(NSString*)content;
@end
