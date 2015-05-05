//
//  AFRViewController.m
//  MSCDemo_UI
//
//  Created by junmei on 14-2-24.
//
//

#import "AFRViewController.h"
#import "Definition.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "PopupView.h"
#import "iflyMSC/IFlySpeechConstant.h"
@interface AFRViewController ()

@end

@implementation AFRViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"音频流识别";
	// Do any additional setup after loading the view.
    self.uploadWordBtn.hidden = YES;
    self.uploadContactBtn.hidden = YES;
    UILabel *custom = (UILabel *)[self.view viewWithTag:9527];
    //custom.hidden = YES;
    
    UIButton *audiobtn = [UIButton buttonWithType:UIButtonTypeRoundedRect] ;
    [audiobtn setTitle:@"音频流识别" forState:UIControlStateNormal];
    audiobtn.frame = CGRectMake(Padding, custom.frame.origin.y + custom.frame.size.height+10, self.view.frame.size.width-Padding*2, ButtonHeight);
    [self.view addSubview:audiobtn];
    [audiobtn addTarget:self action:@selector(audioFileRcg:) forControlEvents:UIControlEventTouchUpInside];
    self.audiobtn = audiobtn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//音频流识别按钮响应函数
- (void)audioFileRcg:(id)sender
{
    //获取音频文件
    NSString *docdir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [docdir stringByAppendingPathComponent:@"asr.pcm"];
    if (![fm fileExistsAtPath:path]) {
        [self.popUpView setText:@"文件不存在"];
        [self.view addSubview:self.popUpView];
        return;
    }
    
    //设置识别音频源为音频流
    [self.iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
    //[self.iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant LOCAL_GRAMMAR]];
    BOOL ret = [self.iFlySpeechRecognizer startListening];
    if (ret) {
        self.isCanceled = NO;
    }
    //从文件中读取音频
    NSData *data = [NSData dataWithContentsOfFile:path];
    int count = 10;
    unsigned long audioLen = data.length/count;
    //分割音频
    for (int i =0 ; i< count-1; i++) {
        char * part1Bytes = malloc(audioLen);
         NSRange range = NSMakeRange(audioLen*i, audioLen);
        [data getBytes:part1Bytes range:range];
        NSData * part1 = [NSData dataWithBytes:part1Bytes length:audioLen];
        //写入音频，让SDK识别
         [self.iFlySpeechRecognizer writeAudio:part1];
        free(part1Bytes);
    }
    //处理最后一部分
    unsigned long writtenLen = audioLen * (count-1);
    char * part3Bytes = malloc(data.length-writtenLen);
    NSRange range = NSMakeRange(writtenLen, data.length-writtenLen);
    [data getBytes:part3Bytes range:range];
    NSData * part3 = [NSData dataWithBytes:part3Bytes length:data.length-writtenLen];
     [self.iFlySpeechRecognizer writeAudio:part3];
    free(part3Bytes);
    
    //通知SDK音频写完
    [self.iFlySpeechRecognizer stopListening];
    [self.iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
}

/*
 * @开始录音
 */
- (void) onBtnStart:(id) sender
{
    self.audiobtn.enabled = NO;
    [super onBtnStart:sender];
}

/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    NSString *text ;
    if (self.isCanceled) {
        text = @"识别取消";
    }
    else if (error.errorCode ==0 ) {
        if (self.result.length==0) {
            text = @"无识别结果";
        }
        else
        {
            text = @"识别成功";
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        NSLog(@"%@",text);
    }
    [self.popUpView setText: text];
    [self.view addSubview:self.popUpView];
    [self.stopBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
     self.audiobtn.enabled = YES;
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{
   
}


@end
