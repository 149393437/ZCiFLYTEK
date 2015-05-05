//
//  TextUnderstanderViewController.h
//  MSCDemo
//
//  Created by AlexHHC on 4/24/14.
//  Copyright (c) 2014 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupView;
/**
 文本语义理解demo
 */
@interface TextUnderstanderViewController : UIViewController<UITextViewDelegate>

@property (nonatomic,strong)        UIBarButtonItem     * clearBtn;//右上角的清空按钮
@property (nonatomic, copy)               NSString            * defaultText;//默认语义理解文本
@property (nonatomic, weak)         UITextView          * resultView;
@property (nonatomic, strong)       PopupView           * popUpView;
@end
