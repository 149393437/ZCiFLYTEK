//
//  TTSViewController.h
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"

@class AlertView;
@class PopupView;
@class IFlySpeechSynthesizer;

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart                 = 0,
    /**高，异常分析需要的级别*/
    Playing              = 2,
    
    Paused              = 4,
};


/**
 语音合成demo
 */
@interface TTSViewController : UIViewController<IFlySpeechSynthesizerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, weak)   UITextView            * toBeSynthersedTextView;
@property (nonatomic, strong) PopupView             * popUpView;
@property (nonatomic, strong) AlertView             * bufferAlertView;
@property (nonatomic, strong) AlertView             * cancelAlertView;
@property (nonatomic, weak)   UIButton              * startBtn;
@property (nonatomic, weak)   UIButton              * cancelBtn;
@property (nonatomic, weak)   UIButton              * setEngineBtn;
@property (nonatomic,weak)    UIButton              * chooseVoiceNameBtn;
@property (nonatomic)         BOOL                   isCanceled;
@property (nonatomic)         BOOL                   hasError;
@property (nonatomic)         BOOL                   isViewDidDisappear;
@property (nonatomic)         CGFloat                textViewHeight;
@property (nonatomic)         Status                 state;
@property (nonatomic, strong) NSArray               * engineTypes;
@property (nonatomic, strong) NSString              * selectedVoiceName;
@property (nonatomic, strong) NSArray               * voiceNameParameters;

-(void)setViewSize:(BOOL)movedUp Notification:(NSNotification*) notification;
@end
