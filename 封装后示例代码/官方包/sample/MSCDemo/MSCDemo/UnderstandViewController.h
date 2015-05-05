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
@class IFlySpeechUnderstander;

/**
 语音理解demo
 */
@interface UnderstandViewController : UIViewController<IFlySpeechRecognizerDelegate>

@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;
@property (nonatomic,weak)   UITextView             *resultView;
@property (nonatomic,strong) PopupView              *popUpView;
@property (nonatomic,weak)   UIButton               *startBtn;
@property (nonatomic,weak)   UIButton               *stopBtn;
@property (nonatomic,weak)   UIButton               *cancelBtn;
@property (nonatomic,strong) NSString               *result;
@property (nonatomic)         BOOL                  isCanceled;

@end
