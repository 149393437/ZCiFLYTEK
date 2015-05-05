//
//  ASRViewController.h
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
 关键词识别demo
 */
@interface ASRViewController : UIViewController<IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic, weak)   UITextView           * resultView;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, weak)   UIButton             * startBtn;
@property (nonatomic, weak)   UIButton             * stopBtn;
@property (nonatomic, weak)   UIButton             * cancelBtn;
@property (nonatomic, weak)   UIButton             * uploadBtn;
@property (nonatomic, strong) IFlyDataUploader     * uploader;
@property (nonatomic, copy)   NSString             * result;
@property (nonatomic)         BOOL                  isCanceled;

-(void)setViewSize:(BOOL)movedUp Notification:(NSNotification*) notification;

@end
