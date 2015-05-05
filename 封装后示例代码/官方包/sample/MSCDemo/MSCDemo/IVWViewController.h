//
//  ISRViewController.h
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyVoiceWakeuperDelegate.h"
#import "iflyMSC/IFlyVoiceWakeuper.h"

//forward declare
@class PopupView;


/**
 无UI语音识别demo
 */
@interface IVWViewController : UIViewController <IFlyVoiceWakeuperDelegate>

@property (nonatomic, weak)   UITextView           * resultView;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, strong) NSString             * result;
@property (nonatomic,strong)  NSDictionary         * words;
@property (nonatomic,strong)  IFlyVoiceWakeuper    * iflyVoiceWakeuper;
@property (nonatomic,weak)    UIButton             * startBtn;
@property (nonatomic,weak)    UIButton             * stopBtn;

@end
