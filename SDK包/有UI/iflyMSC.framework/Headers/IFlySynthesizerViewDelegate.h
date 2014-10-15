//
//  IFlySynthesizerViewDelegate.h
//  msc_UI
//
//  Created by iflytek on 13-4-17.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFlySynthesizerView;
@class IFlySpeechError;

@protocol IFlySynthesizerViewDelegate <NSObject>

/** 合成结束回调
 
 当合成结束时会回调此函数，如果你需要连续合成可在此函数中调用`- (void)startSpeaking:(NSString *)text`函数继续合成
 
 @param iFlySynthesizerView
 @param error 合成结束错误码
 */
- (void) onEnd:(IFlySynthesizerView *) iFlySynthesizerView  error:(IFlySpeechError *)error;

/** 缓冲进度

 @param   iFlySynthesizerView
 @param   progress            缓冲进度，范围为0-100
 */
- (void) onBufferProress:(IFlySynthesizerView *) iFlySynthesizerView progress:(int) progress;

/** 合成进度

 @param   iFlySynthesizerView
 @param   progress            播放进度,范围为0-100
 */
- (void) onPlayProress:(IFlySynthesizerView *) iFlySynthesizerView progress:(int) progress;

@end
