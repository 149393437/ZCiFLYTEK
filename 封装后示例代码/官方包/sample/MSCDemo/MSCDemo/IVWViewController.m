//
//  IVWViewController.m
//
//  Created by xlhou on 14-6-26.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

/*
 *
    demo为唤醒的使用示例
    本次demo假定唤醒词是“讯飞语音”和“讯飞语点”，第一个唤醒词是“讯飞语音”，第二个唤醒词是“讯飞语点”
    总体运行顺序是：
 1. 设置唤醒参数；
 2. 创建唤醒对象；
 3. 启动唤醒；
 4. 通过回调获取唤醒状态
 
 在使用时需要注意唤醒的本地资源路径，一定要与具体的文件保持一致
 *
 *
 */

#import "IVWViewController.h"

#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyVoiceWakeuperDelegate.h"
#import "iflyMSC/IFlyResourceUtil.h"

#import "PopupView.h"
#import "Definition.h"
#import "UIPlaceHolderTextView.h"
#import "RecognizerFactory.h"
#import <QuartzCore/QuartzCore.h>


@interface IVWViewController ()

@end

@implementation IVWViewController


/*
 * @开始启动语音唤醒
 */

- (void) onBtnStart:(id)sender
{
    //设置唤醒门限值
    //0:表示第一个唤醒词，-20表示对应的门限值
    //1：表示第二个唤醒词，-20表示对应的门限值
    //唤醒词的数目跟序号是一一对应的
    [self.iflyVoiceWakeuper setParameter:@"0:-20;1:-20;" forKey:[IFlySpeechConstant IVW_THRESHOLD]];
    
    //设置唤醒服务类型，wakeup表示是唤醒服务，除此外以后还可能有其他拓展服务
    [self.iflyVoiceWakeuper setParameter:@"wakeup" forKey:[IFlySpeechConstant IVW_SST]];
    
    //设置唤醒服务周期，1：表示唤醒成功后继续录音，并保持唤醒状态；0：表示唤醒成功后停止录音
    [self.iflyVoiceWakeuper setParameter:@"1" forKey:[IFlySpeechConstant KEEP_ALIVE]];
    
    BOOL ret = [self.iflyVoiceWakeuper startListening];
    if(ret)
    {
        self.startBtn.enabled = NO;
        self.stopBtn.enabled=YES;
    }
}

- (void)viewDidLoad
{
    //demo中的唤醒词，假定是“讯飞语音”和“讯飞语点”
     self.words = [[NSDictionary alloc]initWithObjectsAndKeys:@"讯飞语音",@"0",@"讯飞语点",@"1",nil];
    [super viewDidLoad];
    
//    NSString *documentsPath = nil;
//    NSArray *appArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    if ([appArray count] > 0) {
//        documentsPath = [appArray objectAtIndex:0];
//    }
//    
//    NSLog(@"documentsPath=%@",documentsPath);
    
    //获取唤醒词路径,目录需要根据具体的文件位置设定
//    NSString *wordPath1 = [[NSBundle mainBundle] pathForResource:@"ivwres/wakupresource" ofType:@"irf"];
    
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *wordPath = [[NSString alloc] initWithFormat:@"%@/ivwres/wakeupresource.jet",resPath];
    
//    FILE *fp = fopen([wordPath UTF8String],"rb");
    
    //转换路径为符合sdk规范的唤醒路径
    NSString *ivwResourcePath = [IFlyResourceUtil generateResourcePath:wordPath];
    
    [[IFlySpeechUtility getUtility] setParameter:[NSString stringWithFormat: @"engine_start=ivw,ivw_res_path=%@",ivwResourcePath] forKey:[IFlyResourceUtil ENGINE_START]];
    
    self.iflyVoiceWakeuper = [IFlyVoiceWakeuper sharedInstance];
    self.iflyVoiceWakeuper.delegate = self;

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
    self.view = mainView;
    
   
    //语音唤醒
    self.title = @"语音唤醒";
     int top = Margin*6;
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:
                                         CGRectMake(Margin*2, top, self.view.frame.size.width-Margin*4, 160)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
    [self.view addSubview:resultView];
    resultView.font = [UIFont systemFontOfSize:17.0f];
    resultView.placeholder = @"唤醒结果";
    [resultView setEditable:NO];
    _resultView = resultView;
    
    
    //开始button
    self.startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.startBtn setTitle:@"开始唤醒" forState:UIControlStateNormal];
    self.startBtn.frame = CGRectMake(Padding, resultView.frame.origin.y + resultView.frame.size.height + Margin, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    [self.view addSubview:self.startBtn];
    [self.startBtn addTarget:self action:@selector(onBtnStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
    
    
    //停止唤醒
    self.stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    self.stopBtn.frame = CGRectMake(self.startBtn.frame.origin.x+ 2*Padding + 2*self.startBtn.frame.size.width, self.startBtn.frame.origin.y, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    self.stopBtn.enabled = NO;
    [self.view addSubview:self.stopBtn];
    
    [self.stopBtn addTarget:self action:@selector(onBtnStop:) forControlEvents:UIControlEventTouchUpInside];
 
    
  //  self.popUpView = [[[PopupView alloc]initWithFrame:CGRectMake(100, 100, 0, 0)] autorelease];
   self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 100, 0, 0)];
    _popUpView.ParentView = self.view;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 录音开始
 */
-(void) onBeginOfSpeech
{
    
}

/**
 录音结束
 */
-(void) onEndOfSpeech
{
   
}

/**
 会话错误
 
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 
 */
-(void) onError:(IFlySpeechError *)error
{
    [self.view addSubview:_popUpView];
    if (error.errorCode!=0) {
        [_popUpView setText:[NSString stringWithFormat:@"识别结束,错误码:%d",error.errorCode]];
        NSLog(@"errorCode:%d",error.errorCode);
    }
    _stopBtn.enabled = NO;
}


/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"音量：%0d",volume];
    [_popUpView setText: vol];
    [self.view addSubview:_popUpView];
    
}


/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的resultID记录唤醒词位置和动作
* @see
 */
-(void) onResult:(NSMutableDictionary *)resultArray
{
    
    NSString *sst = [resultArray objectForKey:@"sst"];
    NSNumber *wakeId = [resultArray objectForKey:@"id"];
    NSString *score = [resultArray objectForKey:@"score"];
    NSString *bos = [resultArray objectForKey:@"bos"];
    NSString *eos = [resultArray objectForKey:@"eos"];
    NSString * wakeIDStr = [NSString stringWithFormat:@"%@",wakeId];
    
    NSLog(@"【唤醒词】=%@",[self.words objectForKey:wakeIDStr]);
    NSLog(@"【操作类型】sst=%@",sst);
    NSLog(@"【唤醒词id】id=%@",wakeId);
    NSLog(@"【得分】score=%@",score);
    NSLog(@"【尾端点】eos=%@",eos);
    NSLog(@"【前端点】bos=%@",bos);
    
    NSLog(@"");
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n"];
    
    [result appendFormat:@"【唤醒词】=%@\n",[self.words objectForKey:wakeIDStr]];
    [result appendFormat:@"【操作类型】sst=%@\n",sst];
    [result appendFormat:@"【唤醒词id】id=%@\n",wakeId];
    [result appendFormat:@"【得分】score=%@\n",score];
    [result appendFormat:@"【尾端点】eos=%@\n",eos];
    [result appendFormat:@"【前端点】bos=%@\n",bos];
    //[result appendString:@"********************分割*********************\n"];
    

    _result = result;
    self.result = result;
    _resultView.text = [NSString stringWithFormat:@"%@%@", _resultView.text,result];
    self.result=nil;
    [_resultView scrollRangeToVisible:NSMakeRange([_resultView.text length], 0)];
}


/*
 *设置回非语言唤醒 释放资源
 */

-(void)viewWillDisappear:(BOOL)animated
{
    self.iflyVoiceWakeuper.delegate = nil;
    [self.iflyVoiceWakeuper cancel];
    [super viewWillDisappear:animated];
}



/*
 * @ 暂停录音 并不释放资源
 *  在后台运行如想暂停录音，调用 IFlyVoiceWakeuper cancel
 *
 * 
 */
- (void) onBtnStop:(id) sender
{
    [self.iflyVoiceWakeuper stopListening];
    self.stopBtn.enabled=NO;
    NSLog(@"唤醒结束");
    [_resultView resignFirstResponder];
     self.startBtn.enabled = YES;
}



@end
