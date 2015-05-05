//
//  ASRDialogViewController.h
//  MSCDemo
//
//  Created by junmei on 14-1-20.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
//forward declare
@class IFlyRecognizerView;
@class PopupView;

/**
 有UI语音识别demo
 */
@interface ASRDialogViewController : UIViewController<IFlyRecognizerViewDelegate>

@property (nonatomic,strong) IFlyRecognizerView * iflyRecognizerView;
@property (nonatomic,strong) PopupView          * popView;
@property (nonatomic,weak)   UITextView         * textView;

@end
