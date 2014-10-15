//
//  IFlySpeechRecognizer.h
//  MSC
//
//  Created by iflytek on 13-3-19.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlySpeechRecognizerDelegate.h"
#import "IFlySpeechError.h"


@class IFlyMscRecognizer;

/** 语音识别类
 
 此类现在设计为单类，你在使用中只需要创建此对象，不能调用release/dealloc函数去释放此对象。所有关于语音识别的操作都在此类中。
 */
@interface IFlySpeechRecognizer : NSObject<IFlySpeechRecognizerDelegate>
{
    IFlyMscRecognizer                       *_mscer;
    
    id<IFlySpeechRecognizerDelegate>       _delegate;
}

/** 设置委托对象 */
@property(assign) id<IFlySpeechRecognizerDelegate> delegate ;

///---------------------------------------------------------------------------------------
/// @name 创建对象
///---------------------------------------------------------------------------------------

/** 创建识别对象的单类
 
 此方法的使用示例如下:
         NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID,TIMEOUT];
         _iFlySpeechRecognizer = [IFlySpeechRecognizer createRecognizer: initString delegate:self];
         [initString release];
 
 params 的参数说明如下：
 
 1. appid:应用程序ID (必选)
 2. timeout:网络超时时间,单位:ms,默认为20000,范围0-30000 (可选)
 3. usr:用户名,开发者在开发者网站上注册的用户名
 4. pwd:用户密码,开发者在开发者网站上的用户密码
 5. server_url:默认连接语音云公网入口 http://dev.voicecloud.cn/index.htm,只有特定业务才需要设 置为固定ip或域名,普通开发者不需要设置
 6. besturl_search:默认为1,如果server_url设置为固定ip地址, 需要将此参数设置为0,表示不寻找最佳服务器。如果 server_url为域名,可以将此参数设置为1
 
 @param params  初始化时的参数，
 @param delegate 委托对象
 */
+ (id) createRecognizer:(NSString *)params delegate:(id<IFlySpeechRecognizerDelegate>) delegate;

/** 获取识别对象
 
 @return 返回创建的识别对象
 */
+ (IFlySpeechRecognizer *) getRecognizer;

///---------------------------------------------------------------------------------------
/// @name 操作
///---------------------------------------------------------------------------------------

/** 设置识别引擎的参数
 
 识别的引擎参数(key)取值如下:
 
 1. domain:应用的领域;取值为iat、at,search,video,poi,music,asr;iat,普通文本转写; search,热词搜索;video,视频音乐搜索;asr: 命令词识别;
 2. vad_bos:前端点检测;静音超时时间,即用户多长时间不说话则当做超 时处理,单位:ms,engine 指定 iat 识别默认值为 5000,其他 情况默认值为 4000,范围 0-10000。
 3. vad_eos:后断点检测;后端点静音检测时间,即用户停止说话多长时间 内即认为不再输入,自动停止录音,单位:ms,sms 识别默认 值为 1800,其他默认值为 700,范围 0-10000。
 4. sample_rate:采样率,目前支持的采样率设置有 16000 和 8000。
 5. asr_ptt:否返回无标点符号文本;默认为 1,当设置为 0 时,将返回无标点符号文本。
 6. asr_sch:是否需要进行语义处理,默认为 0,即不进行语义 识别,对于需要使用语义的应用,需要将 asr_sch 设为 1,并且 设置 plain_result 参数为 1,由外部对结果进行解析。
 7. plain_result:回结果是否在内部进行 json 解析,默认值为 0,即进行解析,返回外部的内容为解析后文本。对于语义等业 务,由于服务端返回内容为 xml 或其他格式,需要应用程序自 行处理,这时候需要设置 plain_result 为 1。
 8. grammarID:识别的语法 id,只针对 domain 设置为”asr”的应用。
 9. params:扩展参数,对于一些特殊的参数可在此设置。
 @param key 识别引擎参数
 @param value 参数对应的取值
 
 @return 设置的参数和取值正确返回YES,失败返回NO
 */
- (BOOL) setParameter:(NSString *) key value:(NSString *) value;

/** 开始识别
 
 同时只能进行一路会话,这次会话没有结束不能进行下一路会话，否则会报错
 */
- (BOOL) startListening;

/** 停止录音
 
 调用此函数会停止录音，并开始进行语音识别
 */
- (void) stopListening;

/** 取消本次会话 */
- (void) cancel;

@end

/** 音频文件识别
 
 音频文件识别不需要录音，只需要一次将音频文件传入就可以。
 */
@interface IFlySpeechRecognizer(IFlyPcmRecognizer)

/** 音频文件识别
 
 @param audioData 音频数据
 */
- (void) recognizeAudio:(NSData *) audioData;

@end


/** 音频流识别

 音频流和音频文件相似，不同的是音频流识别可以将文件分段写入不需要一次写入
 */
@interface IFlySpeechRecognizer(IFlyStreamRecognizer)

/** 音频流识别 */
- (void) recognizeStream;

/** 写入音频流
 
 @param audioData 音频数据
 @param length 长度
 @return 写入成功返回YES，写入失败返回NO
 */
- (BOOL) writeAudio:(NSData *) audioData length:(int) length;

@end

