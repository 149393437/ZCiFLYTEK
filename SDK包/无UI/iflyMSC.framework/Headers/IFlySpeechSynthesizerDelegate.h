//
//  IFlySpeechSynthesizerDelegate.h
//  MSC
//
//  Created by ypzhao on 13-3-20.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFlySpeechError;

/** 语音合成回调 */

@protocol IFlySpeechSynthesizerDelegate <NSObject>

/** 开始合成回调 */
- (void) onSpeakBegin;

/** 缓冲进度回调
 
 @param progress 缓冲进度，0-100
 @param message 附件信息，此版本为nil
 */
- (void) onBufferProgress:(int) progress message:(NSString *)msg;

/** 播放进度
 
 @param progress 播放进度，0-100
 */
- (void) onSpeakProgress:(int) progress;

/** 暂停播放 */
- (void) onSpeakPaused;

/** 恢复播放 */
- (void) onSpeakResumed;

/** 结束回调 
 
 当整个合成结束之后会回调此函数
 
 @param error 错误码
  */
- (void) onCompleted:(IFlySpeechError*) error;

/** 正在取消
 
 当调用`cancel`之后会回调此函数
 */
- (void) onSpeakCancel;

@end
