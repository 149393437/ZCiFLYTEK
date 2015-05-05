//
//  ABNFViewController.h
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
 音频流识别demo
 */
@interface ABNFViewController : UIViewController<IFlySpeechRecognizerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic, weak)   UITextView           * resultView;
@property (nonatomic, strong) PopupView            * popUpView;
@property (nonatomic, weak)   UIButton             * startBtn;
@property (nonatomic, weak)   UIButton             * stopBtn;
@property (nonatomic, weak)   UIButton             * cancelBtn;
@property (nonatomic, weak)   UIButton             * uploadBtn;
@property (nonatomic, strong) IFlyDataUploader     * uploader;
@property (nonatomic, strong) NSMutableString      * curResult;//当前session的结果
@property (nonatomic)         BOOL                  isCanceled;

@property (nonatomic)         NSString             * engineType;//引擎类型
@property (nonatomic)         NSString             * grammarType;//语法类型
@property (nonatomic, strong) NSArray              * engineTypes;

-(void)setViewSize:(BOOL)movedUp Notification:(NSNotification*) notification;
@end
