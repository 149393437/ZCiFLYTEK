//
//  IFlyRecognizerView.h
//  MSC
//
//  Created by admin on 13-4-16.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IFlyRecognizerViewDelegate.h"

@class IFlyRecognizerViewImp;

/** 语音识别控件 */

@interface IFlyRecognizerView : UIView
{
    id<IFlyRecognizerViewDelegate> _delegate;
    IFlyRecognizerViewImp   *_iFlyRecognizerViewImp;
    
}

@property(assign)id<IFlyRecognizerViewDelegate> delegate;

/** 初始化控件
 
 @param origin 控件左上角的坐标
 @param initParam 初始化的参数
 @return 
 */
- (id)initWithOrigin:(CGPoint)origin initParam:(NSString *)initParam;

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
- (BOOL)setParameter:(NSString *)key value:(NSString *)value;

/** 开始识别
 
 @return 成功返回YES；失败返回NO
 */
- (BOOL)start;

/** 取消本次识别  */
- (void)cancel;


@end
