//
//  ZCiFLYTEK.m
//  Xunfei_demo_1401
//
//  Created by ZhangCheng on 14-4-19.
//  Copyright (c) 2014年 zhangcheng. All rights reserved.
//

#import "ZCiFLYTEK.h"

@implementation ZCiFLYTEK
static ZCiFLYTEK *manager=nil;
-(id)init
{
    if (self=[super init]) {
        
    }
    return self;
}
+(id)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager==nil) {
            manager=[[self alloc]init];
        }
    });
    return manager;
}
-(void)playStart:(NSString*)content
{
    iFlySynthesizerView = [[IFlySynthesizerView alloc] initWithOrigin:CGPointMake(20, 60) params:@"appid=52bbb432"];
    iFlySynthesizerView.delegate=self;
    [iFlySynthesizerView startSpeaking:content];
}
-(void)discernBlock:(void (^)(NSString *))a{
    iFlyRecognizerView = [[IFlyRecognizerView alloc] initWithOrigin:CGPointMake(15, 60) initParam:@"appid=52bbb432"];
    iFlyRecognizerView.delegate = self;
    // 参数设置
    self.onResult=a;
    [iFlyRecognizerView setParameter:@"domain" value:@"sms"];
    [iFlyRecognizerView setParameter:@"sample_rate" value:@"16000"];
    [iFlyRecognizerView setParameter:@"vad_eos" value:@"1800"];
    [iFlyRecognizerView setParameter:@"vad_bos" value:@"6000"];
    [iFlyRecognizerView start];
    
}

//代理
//识别完成
- (void) onResult:(IFlyRecognizerView *)iFlyRecognizerView theResult:(NSArray *)resultArray
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@(置信度:%@)\n",key,[dic objectForKey:key]];
        
    }
    
    self.onResult(result);
    
    
    
    
    
    
}
- (void)onEnd:(IFlyRecognizerView *)iFlyRecognizerView theError:(IFlySpeechError *) error
{
    NSLog(@"recognizer end");
}
/****播放的代理****/
- (void) onEnd:(IFlySynthesizerView *)iFlySynthesizerView error:(IFlySpeechError *)error
{
    //播放完成
}
- (void) onPlayProress:(IFlySynthesizerView *)iFlySynthesizerView progress:(int)progress
{
    //播放的进度
}
- (void) onBufferProress:(IFlySynthesizerView *)iFlySynthesizerView progress:(int)progress
{
    //预读的进度
}

@end
