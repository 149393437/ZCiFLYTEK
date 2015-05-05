//
//  ABNFViewController.m
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "ABNFViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "RecognizerFactory.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "PopupView.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import "ISRDataHelper.h"

#define kOFFSET_FOR_KEYBOARD 110.0

#define GRAMMAR_TYPE_BNF    @"bnf"
#define GRAMMAR_TYPE_ABNF    @"abnf"

@implementation ABNFViewController

static NSString * _cloudGrammerid =nil;
static NSString * _localgrammerId = nil;

-(void) setGrammerId:(NSString*) grammarID
{
    _cloudGrammerid = grammarID;
    //[_iFlySpeechRecognizer setParameter:_grammerId forKey:[IFlySpeechConstant LOCAL_GRAMMAR]];
    [_iFlySpeechRecognizer setParameter:grammarID forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
}

- (instancetype) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.engineTypes = @[@"在线",@"本地"];
    self.iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"asr"];
    self.isCanceled = NO;
    
    self.curResult = [[NSMutableString alloc]init];
    
    //默认采用云端引擎
//    self.engineType = [IFlySpeechConstant TYPE_LOCAL];
//    self.grammarType = GRAMMAR_TYPE_BNF;
    
    self.engineType = [IFlySpeechConstant TYPE_CLOUD];
    self.grammarType = GRAMMAR_TYPE_ABNF;
    
    self.uploader = [[IFlyDataUploader alloc] init];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Button handler
/*
 * @ 开始录音
 */
- (void) onBtnStart:(id)sender
{
    if (![self isCommitted]) {
        [_popUpView setText:@"   请先上传\
         语法"];
        [self.view addSubview:_popUpView];
        return;
    }
    
//    [_iFlySpeechRecognizer setParameter:_grammerId forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
    
    BOOL ret = [IFlySpeechRecognizer.sharedInstance startListening];
    if (ret) {
        [_stopBtn setEnabled:YES];
        [_cancelBtn setEnabled:YES];
        self.isCanceled = NO;
        [self.curResult setString:@""];
    }
    else
    {
        [_popUpView setText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束
        [self.view addSubview:_popUpView];
    }
}

/*
 * @ 暂停录音
 */
- (void) onBtnStop:(id) sender
{
    [IFlySpeechRecognizer.sharedInstance stopListening];
    [_resultView resignFirstResponder];
}

/*
 * @取消识别
 */
- (void) onBtnCancel:(id) sender
{
    self.isCanceled = YES;
    [IFlySpeechRecognizer.sharedInstance cancel];
    [_resultView resignFirstResponder];
}

/*
 * @选择识别引擎
 */
- (void) onSetEngineBtn:(id) sender
{
    //[_iFlySpeechRecognizer cancel];
    [_resultView resignFirstResponder];
    UIActionSheet * actionSheet = [[UIActionSheet alloc]                                   initWithTitle:@"选择识别引擎"
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
 * @ 上传语法
 */
- (void) onBtnUpload:(id)sender
{
    [_iFlySpeechRecognizer stopListening];
    _uploadBtn.enabled = NO;
    
    [self showPopup];
    
    /*上传abnf语法时，需要上传的参数*/
#define ABNF        @"sub=asr,dtt=abnf"
    [_uploader setParameter:@"asr" forKey:@"sub"];
    [_uploader setParameter:@"abnf" forKey:@"dtt"];
    
#define ABNFDATA    @"#ABNF 1.0 UTF-8;\n\
language zh-CN;\n\
mode voice;\n\
root $main;\n\
$main = $place1 到 $place2;\n\
$place1 = 北京 | 武汉 | 南京 | 天津 | 天京 |东京;\n\
$place2 = 上海 | 合肥;\n\
"
#define ABNFNAME        @"abnf" //名称可以自定义
    //语法不变，请不要重复上传
    
     [_uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
     NSLog(@"%d",[error errorCode]);
         self.resultView.text = ABNFDATA;
     if (![error errorCode]) {
     [_popUpView setText: @"上传成功"];
     [self.view addSubview:_popUpView];
     }
     else {
     [_popUpView setText: @"上传失败"];
     [self.view addSubview:_popUpView];
     
     }
     [self setGrammerId:grammerID];
     _uploadBtn.enabled = YES;
     }
     name:ABNFNAME data:ABNFDATA];
    

}

/******文件读取******/
-(NSString *)readFile:(NSString *)filePath
{
    NSData *reader = [NSData dataWithContentsOfFile:filePath];
    return [[NSString alloc] initWithData:reader
                                 encoding:NSUTF8StringEncoding];
}

-(BOOL) createDirec:(NSString *) direcName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *subDirectory = [documentsDirectory stringByAppendingPathComponent:direcName];
    
    BOOL ret = YES;
    if(![fileManager fileExistsAtPath:subDirectory])
    {
        // 创建目录
        ret = [fileManager createDirectoryAtPath:subDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return ret;
}

-(void) buildGrammer
{
    //    NSString *grammarContent = nil;
    //    NSString *documentsPath = nil;
    //    NSArray *appArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    if ([appArray count] > 0) {
    //        documentsPath = [appArray objectAtIndex:0];
    //    }
    //    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    //
    //    [self createDirec:@"grm"];
    //
    //    if([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]])
    //    {
    //        //grammar build path
    //        NSString *grammBuildPath = [documentsPath stringByAppendingString:@"/grm"];//ivWordDict.irf
    //
    //        //aitalk resource path
    //        NSString *aitalkResourcePath = [[NSString alloc] initWithFormat:@"fo|%@/aitalkResource/common.jet;fo|%@/aitalkResource/sms.jet",appPath,appPath];
    ////        NSString *aitalkResourcePath = [[NSString alloc] initWithFormat:@"fo|%@/aitalkResource/common.jet",appPath];
    //
    //        //bnf resource
    //        NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/bnf/call.bnf",appPath];
    //        grammarContent = [self readFile:bnfFilePath];
    //
    //        [[IFlySpeechUtility getUtility] setParameter:@"asr" forKey:[IFlyResourceUtil ENGINE_START]];
    //
    //        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    //        [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    //        [_iFlySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //
    //        [_iFlySpeechRecognizer setParameter:grammBuildPath forKey:[IFlyResourceUtil GRM_BUILD_PATH]];
    //
    //        [_iFlySpeechRecognizer setParameter:aitalkResourcePath forKey:[IFlyResourceUtil ASR_RES_PATH]];
    //        [self.iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    //        [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:@"result_encoding"];
    //         [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    ////        [_iFlySpeechRecognizer setParameter:@"call" forKey:@"local_grammer"];
    //    }
    //    else
    //    {
    //        [_iFlySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //        [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    //        [self.iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    //        //bnf resource
    //        NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/bnf/grammar_sample.abnf",appPath];
    //        grammarContent = [self readFile:bnfFilePath];
    //    }
    //
    //    //build grammar
    //    [_iFlySpeechRecognizer buildGrammarCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
    //
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //
    //            if (![error errorCode]) {
    //                NSLog(@"errorCode=%d",[error errorCode]);
    //                [_popUpView setText: @"上传成功"];
    //                [self.view addSubview:_popUpView];
    //                _resultView.text = grammarContent;
    //            }
    //            else {
    //                [_popUpView setText: @"上传失败"];
    //                [self.view addSubview:_popUpView];
    //
    //            }
    //
    //            if ([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]]) {
    //                _localgrammerId = grammerID;
    //                [_iFlySpeechRecognizer setParameter:_localgrammerId  forKey:[IFlySpeechConstant LOCAL_GRAMMAR]];
    //            }
    //            else{
    //                _cloudGrammerid = grammerID;
    //                [_iFlySpeechRecognizer setParameter:_cloudGrammerid forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
    //            
    //            }
    //            
    //            self.uploadBtn.enabled = YES;
    //            
    //        });
    //        
    //    }grammarType:self.grammarType grammarContent:grammarContent];
    //
}

#pragma mark - IFlySpeechRecognizerDelegate
/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [_popUpView setText: vol];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech
{
    [_popUpView setText: @"正在录音"];
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{
    [_popUpView setText: @"停止录音"];
    [self.view addSubview:_popUpView];
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
        if (self.curResult.length==0 || [self.curResult hasPrefix:@"nomatch"]) {
            text = @"无匹配结果";
        }
        else
        {
            text = @"识别成功";
            _resultView.text = _curResult;
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        NSLog(@"%@",text);
    }
    [_popUpView setText: text];
    [self.view addSubview:_popUpView];
    [_stopBtn setEnabled:NO];
    [_cancelBtn setEnabled:NO];
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 * 
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
        if([self.engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]])
        {
//            NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFormAsr:result];
//            [resultString appendString:resultFromJson];
            NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:result];
            [resultString appendString:resultFromJson];
        }
        else
        {
            NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromASRJson:result];
            [resultString appendString:resultFromJson];
        }
        
    }
    if (isLast) {
        NSLog(@"result is:%@",self.curResult);
    }
    [self.curResult appendString:resultString];
//    self.curResult = result;
}

/**
 * @fn      onCancal
 * @brief   取消识别回调
 *
 * @see
 */

- (void) onCancel
{
    [_popUpView setText: @"正在取消"];
    [self.view addSubview:_popUpView];
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
    self.view = mainView;
    self.title = @"语法识别";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Result view
    int height;
    height = self.view.frame.size.height - ButtonHeight*2 - Margin*8-NavigationBarHeight;
    UITextView *resultView = [[UITextView alloc] initWithFrame:
                              CGRectMake(Margin*2, Margin*2, self.view.frame.size.width-Margin*4, height)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
//    resultView.text = @"开始识别前请先点击“上传”按钮上传语法。\n\t上传内容为：\n\t#ABNF 1.0 gb2312;\n\tlanguage zh-CN;\n\tmode voice;\n\troot $main;\n\t$main = $place1 到$place2 ;\n\t$place1 = 北京 | 武汉 | 南京 | 天津 | 天京 | 东京;\n\t$place2 = 上海 | 合肥";
    resultView.font = [UIFont systemFontOfSize:17.0f];
    
    resultView.pagingEnabled = YES;
    UIEdgeInsets aUIEdge = [resultView contentInset]; 
    aUIEdge.left = 10;
    aUIEdge.right = 10;
    aUIEdge.top = 10;
    aUIEdge.bottom = 10;
    resultView.contentInset = aUIEdge;
    [resultView setEditable:NO];
    //[resultView sizeToFit];
    
    //键盘
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    //resultView.inputAccessoryView = toolbar;
    [self.view addSubview:resultView];
    self.resultView = resultView;
    
    //设置识别引擎
    UIButton *engineBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [engineBtn setTitle:@"设置识别引擎" forState:UIControlStateNormal];
    engineBtn.frame = CGRectMake(Padding, resultView.frame.origin.y + resultView.frame.size.height + Margin*2, (self.view.frame.size.width-Padding*4)/2, ButtonHeight);
    
    [self.view addSubview:engineBtn];
    [engineBtn addTarget:self action:@selector(onSetEngineBtn:) forControlEvents:UIControlEventTouchUpInside];
    engineBtn.hidden = YES;
    
    //语法上传
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [uploadBtn setTitle:@"语法上传" forState:UIControlStateNormal];
    uploadBtn.frame = CGRectMake(Padding, engineBtn.frame.origin.y, self.view.frame.size.width-Padding*2, engineBtn.frame.size.height);
//    uploadBtn.frame = CGRectMake(engineBtn.frame.origin.x+ Padding + engineBtn.frame.size.width, engineBtn.frame.origin.y, engineBtn.frame.size.width, engineBtn.frame.size.height);
    [self.view addSubview:uploadBtn];
    [uploadBtn addTarget:self action:@selector(onBtnUpload:) forControlEvents:UIControlEventTouchUpInside];
    self.uploadBtn = uploadBtn;
    
    //开始识别
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startBtn setTitle:@"在线识别" forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(Padding, engineBtn.frame.origin.y + engineBtn.frame.size.height + Padding, (self.view.frame.size.width-Padding*4)/3, engineBtn.frame.size.height);
    [self.view addSubview:startBtn];
    self.startBtn = startBtn;
    [startBtn addTarget:self action:@selector(onBtnStart:) forControlEvents:UIControlEventTouchUpInside];
    
    //停止识别
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    stopBtn.frame = CGRectMake(startBtn.frame.origin.x+ Padding+ startBtn.frame.size.width, startBtn.frame.origin.y, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    [self.view addSubview:stopBtn];
    self.stopBtn = stopBtn;
    [stopBtn addTarget:self action:@selector(onBtnStop:) forControlEvents:UIControlEventTouchUpInside];
    [stopBtn setEnabled:NO];
    
    //取消
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(stopBtn.frame.origin.x+ Padding + stopBtn.frame.size.width, stopBtn.frame.origin.y, stopBtn.frame.size.width, stopBtn.frame.size.height);
    [self.view addSubview:cancelBtn];  
    self.cancelBtn = cancelBtn;
    [cancelBtn addTarget:self action:@selector(onBtnCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setEnabled:NO];
    
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    self.popUpView.ParentView = self.view;
//     _login  = [[DemoLogin alloc]initWithParentView:self.view];
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
    
    CGRect rect = _resultView.frame;
    if (show) {
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    _resultView.frame = rect;
    
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
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant TYPE_CLOUD] forKey:[IFlySpeechConstant ENGINE_TYPE]];//设置回默认的在线识别
    //[_uploader setDelegate:nil];
    //_login.delegate =nil;
    //[IFlySpeechUtility destroy];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
}

/*
 * @隐藏键盘
 */
-(void)onKeyBoardDown:(id) sender
{
    [_resultView resignFirstResponder];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
//    if(![DemoLogin isLogin])
//    {
//        [_login Login];
//    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) showPopup
{
    [_popUpView setText: @"正在上传..."];
    [self.view addSubview:_popUpView];
}

-(BOOL) isCommitted
{
    if ([self.engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]]) {
        if(_localgrammerId == nil || _localgrammerId.length ==0)
            return NO;
    }
    else{
        if (_cloudGrammerid == nil || _cloudGrammerid.length == 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark Set Engine UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            self.engineType  = [IFlySpeechConstant TYPE_CLOUD];
            self.grammarType = GRAMMAR_TYPE_ABNF;
            [self.startBtn setTitle:@"在线识别" forState:UIControlStateNormal];
            break;
        case 1:
            self.engineType  = [IFlySpeechConstant TYPE_LOCAL];
            [self.startBtn setTitle:@"本地识别" forState:UIControlStateNormal];
            self.grammarType = GRAMMAR_TYPE_BNF;
            break;
//        case 2:
//            engine = [IFlySpeechConstant TYPE_MIX];
//            break;
        default:
            break;
    }
    //[_iFlySpeechRecognizer setParameter:engine forKey:[IFlySpeechConstant ENGINE_TYPE]];
}

@end
