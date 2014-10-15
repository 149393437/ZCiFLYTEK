//
//  IFlyRecognizerDelegate.h
//  MSC
//
//  Created by admin on 13-4-16.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlySpeechError.h"

@class IFlyRecognizerView;

@protocol IFlyRecognizerViewDelegate <NSObject>

/** 回调返回识别结果
 
 @param iFlyRecognizerView
 @param resultArray 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 */
- (void)onResult:(IFlyRecognizerView *)iFlyRecognizerView theResult:(NSArray *)resultArray;

/** 识别结束回调
 
 @param iFlyRecognizerView
 @param error 识别结束错误码
 */
- (void)onEnd:(IFlyRecognizerView *)iFlyRecognizerView theError:(IFlySpeechError *) error;

@end
