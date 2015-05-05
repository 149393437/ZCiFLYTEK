//
//  TTSViewController.m
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "TTSViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import "Definition.h"
#import "PopupView.h"
#import "AlertView.h"
//#import "MMPickerView.h"

@implementation TTSViewController

- (instancetype) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
     self.engineTypes = @[@"在线",@"本地"];

    //本地资源打包在app内
//    NSString *resPath = [[NSBundle mainBundle] resourcePath];
//    NSString *newResPath = [[NSString alloc] initWithFormat:@"%@/tts64res/dict.irf;%@/tts64res/resource.irf",resPath,resPath];
    [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
    [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD] forKey:[IFlySpeechConstant ENGINE_TYPE]];
    [_iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
//    [_iFlySpeechSynthesizer setParameter:newResPath forKey:@"tts_res_path"];
    
    [self optionalSetting];
    
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    self.selectedVoiceName = @"小燕";
    self.voiceNameParameters = @[@"xiaoyan",@"xiaoyu",@"vixy",@"vixq",@"vixf"];
    self.cancelAlertView =  [[AlertView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    self.bufferAlertView =  [[AlertView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor whiteColor];
    if (!self) {
        return;
    }
    self.view = mainView;
    self.title = @"语音合成";
    self.view.backgroundColor = [UIColor whiteColor];
    int height;
    height = self.view.frame.size.height - ButtonHeight*2 - Margin*4-NavigationBarHeight-3;
    UITextView * textView;
    textView = [[UITextView alloc] initWithFrame:
                              CGRectMake(Margin*2, Margin*2, self.view.frame.size.width-Margin*4, height)];
    [self.view addSubview:textView];
    self.toBeSynthersedTextView = textView;
    textView.layer.cornerRadius = 8;
    textView.layer.borderWidth = 1;
    textView.font = [UIFont systemFontOfSize:17.0f];
    textView.text = @"       科大讯飞作为中国最大的智能语音技术提供商，在智能语音技术领域有着长期的研究积累、\
并在中文语音合成、语音识别、口语评测等多项技术上拥有国际领先的成果。科大讯飞是我国唯一以语音技术为产业化方\
向的“国家863计划成果产业化基地”、“国家规划布局内重点软件企业”、“国家火炬计划重点高新技术企业”、\
“国家高技术产业化示范工程”，并被信息产业部确定为中文语音交互技术标准工作组组长单位，\
牵头制定中文语音技术标准。2003年，科大讯飞获迄今中国语音产业唯一的“国家科技进步奖（二等）”，\
2005年获中国信息产业自主创新最高荣誉“信息产业重大技术发明奖”。2006年至2009年，\
连续四届英文语音合成国际大赛（Blizzard Challenge ）荣获第一名。2008年获国际说话人识别评测大赛\
（美国国家标准技术研究院—NIST 2008）桂冠，2009年获得国际语种识别评测大赛（NIST 2009）高难度混淆方言\
测试指标冠军、通用测试指标亚军";
    textView.textAlignment = IFLY_ALIGN_CENTER;
    self.textViewHeight = _toBeSynthersedTextView.frame.size.height;
    //_toBeSynthersedTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //键盘
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    textView.inputAccessoryView = toolbar;
    textView.textAlignment = IFLY_ALIGN_LEFT;
    //[_toBeSynthersedTextView sizeToFit];
    
    //设置引擎（暂只支持在线合成）
    UIButton*  setEngineBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setEngineBtn setTitle:@"设置引擎" forState:UIControlStateNormal];
    int startBtnTop;
    startBtnTop = _toBeSynthersedTextView.frame.size.height + _toBeSynthersedTextView.frame.origin.y + Margin;
    setEngineBtn.frame = CGRectMake(Padding, startBtnTop, (self.view.frame.size.width-Padding*3)/2, ButtonHeight);
    [self.view addSubview:setEngineBtn];
    [setEngineBtn addTarget:self action:@selector(onSetEngineBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.setEngineBtn =  setEngineBtn;
    setEngineBtn.enabled = NO;
    //self.startBtn =setEngineBtn;
    
    //选择发音人
    UIButton *chooseVoiceNameBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chooseVoiceNameBtn setTitle:@"选择发音人" forState:UIControlStateNormal];
    chooseVoiceNameBtn.frame = CGRectMake(setEngineBtn.frame.origin.x+ Padding +  setEngineBtn.frame.size.width, setEngineBtn.frame.origin.y, setEngineBtn.frame.size.width ,setEngineBtn.frame.size.height);
    [self.view addSubview: chooseVoiceNameBtn];
    [chooseVoiceNameBtn addTarget:self action:@selector(onChooseVoiceNameBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.chooseVoiceNameBtn = chooseVoiceNameBtn;
    self.chooseVoiceNameBtn.enabled = YES;
    
    //开始合成
    UIButton*  startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startBtn setTitle:@"在线合成" forState:UIControlStateNormal];
    startBtn.frame =  CGRectMake(Padding, setEngineBtn.frame.origin.y + setEngineBtn.frame.size.height + Margin, (self.view.frame.size.width-Padding*3)/2, ButtonHeight);
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(onStart:) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn =startBtn;
    
    //取消 
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(startBtn.frame.origin.x+ Padding +  startBtn.frame.size.width, startBtn.frame.origin.y, startBtn.frame.size.width ,startBtn.frame.size.height);
    [self.view addSubview: cancelBtn];
   [cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.enabled = NO;
    self.cancelBtn = cancelBtn;
    
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    _popUpView.ParentView = self.view;
}

/*
 * @隐藏键盘
 */
-(void)onKeyBoardDown:(id) sender
{
    [_toBeSynthersedTextView resignFirstResponder];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    //[_iFlySpeechSynthesizer stopSpeaking];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotate
{
    return NO;
}


-(void)keyboardWillShow:(NSNotification *)aNotification {
        [self setViewSize:YES Notification:aNotification];
}

-(void)keyboardWillHide :(NSNotification *)aNotification{
    [self setViewSize:NO Notification:aNotification ];
}


//method to change the size of view whenever the keyboard is shown/dismissed
-(void)setViewSize:(BOOL)show Notification:(NSNotification*) notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    int height = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect rect = _toBeSynthersedTextView.frame;
    if (show) {
        rect.size.height = self.view.frame.size.height - height- Margin*4;
    }
    else
    {
        rect.size.height = _textViewHeight;
    }
    _toBeSynthersedTextView.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //可选设置
    [self changeAudioSessionWithPlayback: kAudioSessionCategory_MediaPlayback];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.isViewDidDisappear = true;
    
    [_iFlySpeechSynthesizer stopSpeaking];
    _iFlySpeechSynthesizer.delegate = nil;
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    //可选设置
    [self changeAudioSessionWithPlayback: kAudioSessionCategory_PlayAndRecord];
    [super viewWillDisappear:animated];
}

- (void)changeAudioSessionWithPlayback:(UInt32) sessionCategory1
{
    //优化蓝牙播放音质，去杂音
        OSStatus error ;
        error = AudioSessionSetProperty (
                                         kAudioSessionProperty_AudioCategory,
                                         sizeof (sessionCategory1),
                                         &sessionCategory1
                                         );
        if (error) {
            NSLog(@"%s| AudioSessionSetProperty kAudioSessionProperty_AudioCategory error",__func__);
        }
    
    // check the audio route
    UInt32 size = sizeof(CFStringRef);
    CFStringRef route;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
    
    NSLog(@"route = %@", route);
    
    CFRelease(route);
    // if bluetooth headset connected, should be "HeadsetBT"
    // if not connected, will be "ReceiverAndMicrophone"
}

#pragma mark - Button Handler
/*
 * @设置引擎
 */
- (void) onSetEngineBtn:(id) sender
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择引擎"
    delegate:self cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitles:nil];
    
    for (NSString* type in self.engineTypes) {
        [actionSheet addButtonWithTitle:type];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

/*
 * @选择发音人
 */
- (void) onChooseVoiceNameBtn:(id) sender
{
    NSArray *voiceNames = @[@"小燕", @"小宇", @"小研", @"小琪",@"小峰"];
    //https://github.com/madjid/MMPickerView
//    [MMPickerView showPickerViewInView:self.view
//                           withStrings:voiceNames
//                           withOptions:@{MMbuttonColor: [UIColor whiteColor],
//                                         MMtoolbarColor:[UIColor blackColor],
//                                         MMselectedObject:self.selectedVoiceName}
//                            completion:^(NSString *selectedString) {
//                                self.selectedVoiceName = selectedString;
//                                NSUInteger selectedIndex =   [voiceNames indexOfObject:selectedString];
//                                if (selectedIndex!= NSNotFound) {
//                                    NSString* paramter = voiceNameParameters [selectedIndex];
//                                    [_iFlySpeechSynthesizer setParameter:paramter forKey:[IFlySpeechConstant VOICE_NAME]];
//                                }
//                            }];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择发音人" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    actionSheet.tag = 1;
    for (NSString* type in voiceNames) {
        [actionSheet addButtonWithTitle:type];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
   
}

/*
 * @开始播放
 */
- (void) onStart:(id) sender
{
    if (_state == NotStart) {
        self.hasError = NO;
        [NSThread sleepForTimeInterval:0.05];
        _bufferAlertView.ParentView = self.view;
        [_bufferAlertView setText: @"正在缓冲..."];
        [_popUpView removeFromSuperview];
        [self.view addSubview:_bufferAlertView];
        _cancelBtn.enabled = YES;
        self.isCanceled = NO;
        self.setEngineBtn.enabled = NO;
        self.chooseVoiceNameBtn.enabled = NO;
        [_iFlySpeechSynthesizer startSpeaking:_toBeSynthersedTextView.text];
        if (_iFlySpeechSynthesizer.isSpeaking) {
         _state = Playing;
         [_startBtn setTitle:@"暂停播放" forState:UIControlStateNormal];
        }
    }
    else if(_state == Playing)
    {
        if (_hasError) {
            return;
        }
        [_iFlySpeechSynthesizer pauseSpeaking];
    }
    else if(_state == Paused)
    {
        if (_hasError) {
            return;
        }
        [_iFlySpeechSynthesizer resumeSpeaking];
    }

}

/*
 * @取消播放
 */
- (void) onCancel:(id) sender
{
    [_iFlySpeechSynthesizer stopSpeaking];
    _cancelBtn.enabled = NO;
    _startBtn.enabled = NO;
}

#pragma mark - IFlySpeechSynthesizerDelegate

/**
 * @fn      onSpeakBegin
 * @brief   开始播放
 *
 * @see
 */
- (void) onSpeakBegin
{
    [_bufferAlertView dismissModalView];
    [_cancelAlertView dismissModalView];
    self.isCanceled = NO;
    [_popUpView setText:@"开始播放"];
    [self.view addSubview:_popUpView];
    _cancelBtn.enabled = YES;
}

/**
 * @fn      onBufferProgress
 * @brief   缓冲进度
 *
 * @param   progress            -[out] 缓冲进度
 * @param   msg                 -[out] 附加信息
 * @see
 */
- (void) onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"bufferProgress:%d,message:%@",progress,msg);    
}

/**
 * @fn      onSpeakProgress
 * @brief   播放进度
 *
 * @param   progress            -[out] 播放进度
 * @see
 */
- (void) onSpeakProgress:(int) progress
{
    NSLog(@"play progress:%d",progress);
}

/**
 * @fn      onSpeakPaused
 * @brief   暂停播放
 *
 * @see
 */
- (void) onSpeakPaused
{
    [_bufferAlertView dismissModalView];
    [_cancelAlertView dismissModalView];
    _state = Paused;
    [_startBtn setTitle:@"恢复播放" forState:UIControlStateNormal];
    [_popUpView setText:@"播放暂停"];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onSpeakResumed
 * @brief   恢复播放
 *
 * @see
 */
- (void) onSpeakResumed
{
    [_popUpView setText:@"播放继续"];
    [self.view addSubview:_popUpView];
    _state = Playing;
    [_startBtn setTitle:@"暂停播放" forState:UIControlStateNormal];

}

/**
 * @fn      onCompleted
 * @brief   结束回调
 *
 * @param   error               -[out] 错误对象
 * @see
 */
- (void) onCompleted:(IFlySpeechError *) error
{
    NSString *text ;
    if (self.isCanceled)
    {
        text = @"合成已取消";
    }
    else if (error.errorCode ==0 )
    {
        text = @"合成结束";
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        self.hasError = YES;
        NSLog(@"%@",text);
    }
    [_cancelAlertView dismissModalView];
    [_bufferAlertView dismissModalView];
    
    [_popUpView setText: text];
    [self.view addSubview:_popUpView];

   
    _startBtn.enabled = YES;
    _setEngineBtn.enabled = YES;
    _cancelBtn.enabled = NO;
    _state = NotStart;
    NSString * engineType = [_iFlySpeechSynthesizer parameterForKey:[IFlySpeechConstant ENGINE_TYPE]];//设置本地合成
    if ([engineType isEqualToString:[IFlySpeechConstant TYPE_CLOUD]]) {
        [_startBtn setTitle:@"在线合成" forState:UIControlStateNormal];
         _chooseVoiceNameBtn.enabled = YES;
    }
    else  if ([engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]]) {
        [_startBtn setTitle:@"本地合成" forState:UIControlStateNormal];
    }
    
}



/**
 * @fn      onSpeakCancel
 * @brief   正在取消
 *
 * @see
 */
- (void) onSpeakCancel
{
    if (_isViewDidDisappear) {
        return;
    }
    self.isCanceled = YES;
    [_bufferAlertView dismissModalView];
    _cancelAlertView.ParentView = self.view;
    [_cancelAlertView setText: @"正在取消..."];
    [_popUpView removeFromSuperview];
    [self.view addSubview:_cancelAlertView];
}

#pragma mark Set Engine UIActionSheetDelegate

/**
 * @fn      actionSheet
 * @brief  设置引擎 and 选择发音人
 *
 * @see
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //选择发音人
    if(actionSheet.tag==1 && buttonIndex!= actionSheet.cancelButtonIndex)
    {
        self.selectedVoiceName = self.voiceNameParameters[buttonIndex];
        [_iFlySpeechSynthesizer setParameter:self.selectedVoiceName forKey:[IFlySpeechConstant VOICE_NAME]];
    }
    else//设置引擎（暂只支持在线合成）
    {
        
        NSString * engine;
        switch (buttonIndex) {
            case 0:
                [self.startBtn setTitle:@"在线合成" forState:UIControlStateNormal];
                engine = [IFlySpeechConstant TYPE_CLOUD];
                self.chooseVoiceNameBtn.enabled = YES;
                [_popUpView setText:[NSString stringWithFormat: @"在线合成,发音人:%@",self.selectedVoiceName]];
                [self.view addSubview:_popUpView];
                break;
            case 1:
            {
                [self.startBtn setTitle:@"本地合成" forState:UIControlStateNormal];
                engine = [IFlySpeechConstant TYPE_LOCAL];
                
                [_iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
                [_popUpView setText:@"本地合成,发音人:小燕"];
                [self.view addSubview:_popUpView];
                self.chooseVoiceNameBtn.enabled = NO;
                self.selectedVoiceName = @"小燕";
                break;
            }
                //        case 2:
                //            engine = [IFlySpeechConstant TYPE_MIX];
                //            break;
            default:
                break;
        }
        [_iFlySpeechSynthesizer setParameter:engine forKey:[IFlySpeechConstant ENGINE_TYPE]];//设置本地合成
    }
}

-(void) optionalSetting
{
    // 可以自定义音频队列的配置（可选)，例如以下是配置连接非A2DP蓝牙耳机的代码
    //注意：
    //1. iOS 6.0 以上有效，6.0以下按类似方法配置
    //2. 如果仅仅使用语音合成TTS，并配置AVAudioSessionCategoryPlayAndRecord，可能会被拒绝上线appstore
    //    AVAudioSession * avSession = [AVAudioSession sharedInstance];
    //    NSError * setCategoryError;
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f) {
    //        [avSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&setCategoryError];
    //    }
    
    /*
     // 设置语音合成的参数【可选】
     [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
     [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
     //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
     [_iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
     //音频采样率,目前支持的采样率有 16000 和 8000;
     [_iFlySpeechSynthesizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
     
     //当你再不需要保存音频时，请在必要的地方加上这行。
     
     [_iFlySpeechSynthesizer setParameter:@"" forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];//合成的语速,取值范围 0~100
     //[_iFlySpeechSynthesizer setParameter:@"tts.pcm" forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
     
     [_iFlySpeechSynthesizer setParameter:@"2" forKey:@"rdn"];
     */
   
}
@end
