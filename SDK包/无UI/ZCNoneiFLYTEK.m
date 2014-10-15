//
//  ZCNoneiFLYTEK.m
//  讯飞无UIdemo
//
//  Created by ZhangCheng on 14-4-18.
//  Copyright (c) 2014年 ZhangCheng. All rights reserved.
//

#import "ZCNoneiFLYTEK.h"

@implementation ZCNoneiFLYTEK
static ZCNoneiFLYTEK *manager=nil;
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
//播放语音
-(void)playVoice:(NSString*)str{
    iFlySpeechSynthesizer = [IFlySpeechSynthesizer createWithParams:@"appid=52bbb432" delegate:self];
    iFlySpeechSynthesizer.delegate = self;
    // 设置语音合成的参数
    [iFlySpeechSynthesizer setParameter:@"speed" value:@"50"];//合成的语速,取值范围 0~100
    [iFlySpeechSynthesizer setParameter:@"volume" value:@"50"];//合成的音量;取值范围 0~100
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [iFlySpeechSynthesizer setParameter:@"voice_name" value:@"xiaoyan"];
    [iFlySpeechSynthesizer setParameter:@"sample_rate" value:@"8000"];//音频采样率,目前支持的采样率有 16000 和 8000;
    
    [iFlySpeechSynthesizer startSpeaking:str];
    
}
-(void)discernBlock:(void(^)(NSString*))a{
    self.onResult=a;
    
    iflySpeechRecognizer = [IFlySpeechRecognizer createRecognizer: @"appid=52bbb432,timeout=20000" delegate:self];//时间按照毫秒计算
    iflySpeechRecognizer.delegate = self;//请不要删除这句，据说这货是个单例，需要重新设置代理的
    [iflySpeechRecognizer setParameter:@"domain" value:@"sms"];
    [iflySpeechRecognizer setParameter:@"sample_rate" value:@"16000"];
    [iflySpeechRecognizer setParameter:@"plain_result" value:@"0"];
    [iflySpeechRecognizer setParameter:@"vad_eos" value:@"1800"];//设置多少毫秒后断开录音
    
    
    BOOL ret = [iflySpeechRecognizer startListening];
    
    
    //    //停止录音会自动开始识别
    //
    //    [iflySpeechRecognizer stopListening];
    //
    //
    //    //取消识别
    //    [iflySpeechRecognizer cancel];
    
    
}


#pragma mark 语音播放的代理函数
/** 开始合成回调 */
- (void) onSpeakBegin{
    
}
/** 缓冲进度回调
 @param progress 缓冲进度，0-100
 @param message 附件信息，此版本为nil
 */
- (void) onBufferProgress:(int) progress message:(NSString *)msg{
    
}

/** 播放进度
 
 @param progress 播放进度，0-100
 */
- (void) onSpeakProgress:(int) progress{
    
}

/** 暂停播放 */
- (void) onSpeakPaused{
    
}

/** 恢复播放 */
- (void) onSpeakResumed{
    
}

/** 结束回调
 
 当整个合成结束之后会回调此函数
 @param error 错误码
 */

- (void) onCompleted:(IFlySpeechError*) error{
    
}
/** 正在取消
 
 当调用`cancel`之后会回调此函数
 */
- (void) onSpeakCancel{
    
}


#pragma mark 语音识别代理

/** 音量变化回调
 
 在录音过程中，回调音频的音量。
 
 @param volume -[out] 音量，范围从1-100
 */
- (void) onVolumeChanged: (int)volume{
    
}

/** 开始录音回调
 
 当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。如果发生错误则回调onError:函数
 */
- (void) onBeginOfSpeech{
    
}

/** 停止录音回调
 
 当调用了`stopListening`函数或者引擎内部自动检测到断点，如果没有发生错误则回调此函数。如果发生错误则回调onError:函数
 */
- (void) onEndOfSpeech{
    
}

/** 识别结果回调
 
 在进行语音识别过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理，当errorCode没有错误时，表示此次会话正常结束，否则，表示此次会话有错误发生。特别的当调用`cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函数之前如果重新调用了`startListenging`函数则会报错误。
 
 @param errorCode 错误描述类，
 */
- (void) onError:(IFlySpeechError *) errorCode{
    
}
/** 识别结果回调
 
 在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 
 
 @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度。
 */
- (void) onResults:(NSArray *) results{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    for (NSString *key in dic) {
        id value = [dic objectForKey:key];
        [result appendFormat:@"%@ (置信度:%@)\n",key,value];
    }
    
    self.onResult(result);
    NSLog(@"识别结果%@",result);
    
    
    
}

/** 取消识别回调
 
 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 */
- (void) onCancel{
    
}

@end
