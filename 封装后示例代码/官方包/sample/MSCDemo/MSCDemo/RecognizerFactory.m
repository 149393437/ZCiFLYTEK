//
//  RecognizerFactory.m
//  MSCDemo
//
//  Created by iflytek on 13-6-9.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "RecognizerFactory.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "Definition.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"

@implementation RecognizerFactory

+(id) CreateRecognizer:(id)delegate Domain:(NSString*) domain
{
    IFlySpeechRecognizer * iflySpeechRecognizer = nil;
    
    // 创建识别对象
    //NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID,TIMEOUT];
    iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    iflySpeechRecognizer.delegate = delegate;//请不要删除这句,createRecognizer是单例方法，需要重新设置代理
    [iflySpeechRecognizer setParameter:domain forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [iflySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    [iflySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    // | result_type   | 返回结果的数据格式，可设置为json，xml，plain，默认为json。
  //  [iflySpeechRecognizer setParameter:@"xml" forKey:[IFlySpeechConstant RESULT_TYPE]];
       [iflySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    return iflySpeechRecognizer;
}
@end
