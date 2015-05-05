//
//  ASRDialogViewController.m
//  MSCDemo
//
//  Created by junmei on 14-1-20.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import "ASRDialogViewController.h"
#import "Definition.h"
#import "UIPlaceHolderTextView.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "PopupView.h"

@interface ASRDialogViewController ()

@end

@implementation ASRDialogViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:
                                         CGRectMake(Margin*2, Margin*2, self.view.frame.size.width-Margin*4, 300)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
    [self.view addSubview:resultView];
    resultView.font = [UIFont systemFontOfSize:17.0f];
    resultView.placeholder = @"识别结果";
    resultView.editable = NO;
    _textView = resultView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(Margin*2, resultView.frame.origin.y+resultView.frame.size.height+Padding, self.view.frame.size.width-Margin*4, 50);
    [button setTitle:@"开始识别" forState:UIControlStateNormal];
    [button setTitle:@"开始识别" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(startListenning:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _popView = [[PopupView alloc] initWithFrame:CGRectMake(100, 300, 0, 0)];
    _popView.ParentView = self.view;
    
    self.iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
    
    [_iflyRecognizerView setParameter: @"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflyRecognizerView setParameter: @"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    // | result_type   | 返回结果的数据格式，可设置为json，xml，plain，默认为json。
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
//    [_iflyRecognizerView setParameter:@"asr_audio_path" value:nil];   当你再不需要保存音频时，请在必要的地方加上这行。
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 启动按钮响应方法
 */
- (void)startListenning:(id)sender
{
    [_iflyRecognizerView start];
    NSLog(@"start listenning...");
}

#pragma mark IFlyRecognizerViewDelegate
/** 识别结果回调方法
 @param resultArray 结果列表
 @param isLast YES 表示最后一个，NO表示后面还有结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,result];
}

/** 识别结束回调方法
 @param error 识别错误
 */
- (void)onError:(IFlySpeechError *)error
{
    [self.view addSubview:_popView];
    [_popView setText:[NSString stringWithFormat:@"识别结束,错误码:%d",[error errorCode]]];
    NSLog(@"errorCode:%d",[error errorCode]);
}

@end
