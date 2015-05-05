//
//  ISRViewController.h
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"

//forward declare
@class PopupView;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

/**
 无UI语音识别demo
 */
@interface ISRViewController : UIViewController<IFlySpeechRecognizerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic, weak)   UITextView           * resultView;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, weak)   UIButton             * startBtn;
@property (nonatomic, weak)   UIButton             * stopBtn;
@property (nonatomic, weak)   UIButton             * cancelBtn;
@property (nonatomic, weak)   UIButton             * uploadWordBtn;
@property (nonatomic, weak)   UIButton             * uploadContactBtn;
@property (nonatomic, strong) IFlyDataUploader     * uploader;
@property (nonatomic, strong) NSString             * result;
@property (nonatomic)         BOOL                 isCanceled;
@property (nonatomic, strong) NSArray              * engineTypes;
@property (nonatomic)         NSString             * engineType;//引擎类型

- (void) onBtnStart:(id) sender;
@end
