//
//  ISEViewController.m
//  MSCDemo_UI
//
//  Created by 张剑 on 15/1/15.
//
//

#import "ISEViewController.h"
#import "ISESettingViewController.h"
#import "PopupView.h"
#import "ISEParams.h"
#import "IFlyMSC/IFlyMSC.h"

#import "ISEResult.h"
#import "ISEResultXmlParser.h"
#import "Definition.h"



#define _DEMO_UI_MARGIN            5
#define _DEMO_UI_PADDING          10


#define _DEMO_UI_BUTTON_HEIGHT           44
#define _DEMO_UI_NAVIGATIONBAR_HEIGHT    44
#define _DEMO_UI_TOOLBAR_HEIGHT          44
#define _DEMO_UI_STATUSBAR_HEIGHT        20
#define _DEMO_UI_TOP_MARGIN_IOS7         (_DEMO_UI_NAVIGATIONBAR_HEIGHT+_DEMO_UI_STATUSBAR_HEIGHT)


#pragma mark - const values

NSString* const KCIseViewControllerTitle=@"语音评测";
NSString* const KCIseHideBtnTitle=@"隐藏";
NSString* const KCIseSettingBtnTitle=@"设置";
NSString* const KCIseStartBtnTitle=@"开始评测";
NSString* const KCIseStopBtnTitle=@"停止评测";
NSString* const KCIseParseBtnTitle=@"结果解析";
NSString* const KCIseCancelBtnTitle=@"取消评测";

NSString* const KCTextCNSyllable=@"text_cn_syllable";
NSString* const KCTextCNWord=@"text_cn_word";
NSString* const KCTextCNSentence=@"text_cn_sentence";
NSString* const KCTextENWord=@"text_en_word";
NSString* const KCTextENSentence=@"text_en_sentence";

NSString* const KCResultNotify1=@"请点击“开始评测”按钮";
NSString* const KCResultNotify2=@"请朗读以上内容";
NSString* const KCResultNotify3=@"停止评测，结果等待中...";


#pragma mark -

@interface ISEViewController () <IFlySpeechEvaluatorDelegate ,ISESettingDelegate ,ISEResultXmlParserDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) CGFloat textViewHeight;
@property (nonatomic, strong) UITextView *resultView;
@property (nonatomic, strong) NSString* resultText;
@property (nonatomic, assign) CGFloat resultViewHeight;

@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *parseBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) PopupView *popupView;
@property (nonatomic, strong) ISESettingViewController *settingViewCtrl;
@property (nonatomic, strong) IFlySpeechEvaluator *iFlySpeechEvaluator;

@property (nonatomic, assign) BOOL isSessionResultAppear;
@property (nonatomic, assign) BOOL isSessionEnd;

@property (nonatomic, assign) BOOL isValidInput;

@end

@implementation ISEViewController

static NSString *LocalizedEvaString(NSString *key, NSString *comment) {
    return NSLocalizedStringFromTable(key, @"eva/eva", comment);
}

#pragma mark -

- (instancetype)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	_iFlySpeechEvaluator = [IFlySpeechEvaluator sharedInstance];
	_iFlySpeechEvaluator.delegate = self;

	//清空参数
	[_iFlySpeechEvaluator setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    _isSessionResultAppear=YES;
    _isSessionEnd=YES;
    _isValidInput=YES;

	return self;
}

/*!
 *  设置界面加载
 */
- (void)loadView {
	[super loadView];

	// adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
	if (IOS7_OR_LATER) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
		self.extendedLayoutIncludesOpaqueBars = NO;
		self.modalPresentationCapturesStatusBarAppearance = NO;
		self.navigationController.navigationBar.translucent = NO;
	}
#endif

	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	UIView *mainView = [[UIView alloc] initWithFrame:frame];
	mainView.backgroundColor = [UIColor blackColor];
	self.view = mainView;
	self.title = KCIseViewControllerTitle;

	int textViewHeight = self.view.frame.size.height - _DEMO_UI_BUTTON_HEIGHT * 2 - _DEMO_UI_MARGIN * 10 - _DEMO_UI_NAVIGATIONBAR_HEIGHT;

	//textView
	UITextView *textView = [[UITextView alloc] initWithFrame:
	                        CGRectMake(_DEMO_UI_MARGIN * 2,
	                                   _DEMO_UI_MARGIN * 2,
	                                   self.view.frame.size.width - _DEMO_UI_MARGIN * 4,
	                                   textViewHeight / 2)];
	textView.layer.cornerRadius = 8;
	textView.layer.borderWidth = 1;
    textView.layer.borderColor =[[UIColor whiteColor] CGColor];
	textView.text = @"";
	textView.font = [UIFont systemFontOfSize:17.0f];
    textView.textColor=[UIColor whiteColor];
	textView.pagingEnabled = YES;
    textView.backgroundColor=[UIColor blackColor];

	UIEdgeInsets edgeInsets = [textView contentInset];
	edgeInsets.left = 10;
	edgeInsets.right = 10;
	edgeInsets.top = 10;
	edgeInsets.bottom = 10;
	textView.contentInset = edgeInsets;
	[textView setEditable:YES];
	self.textView = textView;
    self.textViewHeight=self.textView.frame.size.height;
	[self.view addSubview:textView];

	//resultView
	UITextView *resultView = [[UITextView alloc] initWithFrame:
	                          CGRectMake(_DEMO_UI_MARGIN * 2,
	                                     textView.frame.size.height + _DEMO_UI_MARGIN * 3,
	                                     self.view.frame.size.width - _DEMO_UI_MARGIN * 4,
	                                     textViewHeight / 2)];
	resultView.layer.cornerRadius = 8;
	resultView.layer.borderWidth = 1;
    resultView.layer.borderColor =[[UIColor whiteColor] CGColor];
	resultView.text = @"";
	resultView.font = [UIFont systemFontOfSize:17.0f];
    resultView.textColor=[UIColor whiteColor];
	resultView.pagingEnabled = YES;
    resultView.backgroundColor=[UIColor blackColor];

	resultView.contentInset = edgeInsets;
	[resultView setEditable:NO];
	self.resultView = resultView;
    self.resultView.text =KCResultNotify1;
    self.resultViewHeight=self.resultView.frame.size.height;
	[self.view addSubview:resultView];

	//键盘工具栏
	UIBarButtonItem *spaceBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
	                                                                              target:nil
	                                                                              action:nil];
	UIBarButtonItem *hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:KCIseHideBtnTitle
	                                                                style:UIBarButtonItemStylePlain
	                                                               target:self
	                                                               action:@selector(onKeyBoardDown:)];
    [hideBtnItem setTintColor:[UIColor whiteColor]];
	UIToolbar *keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _DEMO_UI_TOOLBAR_HEIGHT)];
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	NSArray *array = [NSArray arrayWithObjects:spaceBtnItem, hideBtnItem, nil];
	[keyboardToolbar setItems:array];
    textView.inputAccessoryView = keyboardToolbar;
    textView.textAlignment = IFLY_ALIGN_LEFT;


	//开始
	UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    startBtn.tintColor=[UIColor whiteColor];
	[startBtn setTitle:KCIseStartBtnTitle forState:UIControlStateNormal];
	startBtn.frame = CGRectMake(_DEMO_UI_MARGIN * 2,
	                            resultView.frame.origin.y + resultView.frame.size.height + _DEMO_UI_MARGIN,
	                            (self.view.frame.size.width - _DEMO_UI_PADDING * 3) / 2,
	                            _DEMO_UI_BUTTON_HEIGHT);

	[startBtn addTarget:self action:@selector(onBtnStart:) forControlEvents:UIControlEventTouchUpInside];
	self.startBtn = startBtn;
	[self.view addSubview:startBtn];

	UIButton *parseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    parseBtn.tintColor=[UIColor whiteColor];
	[parseBtn setTitle:KCIseParseBtnTitle forState:UIControlStateNormal];
	parseBtn.frame = CGRectMake(startBtn.frame.origin.x + _DEMO_UI_PADDING + startBtn.frame.size.width,
	                            resultView.frame.origin.y + resultView.frame.size.height + _DEMO_UI_MARGIN,
	                            startBtn.frame.size.width,
	                            startBtn.frame.size.height);

	[parseBtn addTarget:self action:@selector(onBtnParse:) forControlEvents:UIControlEventTouchUpInside];
	self.parseBtn = parseBtn;
	[self.view addSubview:parseBtn];

	//停止
	UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopBtn.tintColor=[UIColor whiteColor];
	[stopBtn setTitle:KCIseStopBtnTitle forState:UIControlStateNormal];
	stopBtn.frame = CGRectMake(_DEMO_UI_PADDING,
	                           startBtn.frame.origin.y + startBtn.frame.size.height + _DEMO_UI_MARGIN,
	                           (self.view.frame.size.width - _DEMO_UI_PADDING * 3) / 2,
	                           _DEMO_UI_BUTTON_HEIGHT);
	[stopBtn addTarget:self action:@selector(onBtnStop:) forControlEvents:UIControlEventTouchUpInside];
	self.stopBtn = stopBtn;
	[self.view addSubview:stopBtn];


	//取消
	UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.tintColor=[UIColor whiteColor];
	[cancelBtn setTitle:KCIseCancelBtnTitle forState:UIControlStateNormal];
	cancelBtn.frame = CGRectMake(stopBtn.frame.origin.x + _DEMO_UI_PADDING + stopBtn.frame.size.width,
	                             stopBtn.frame.origin.y,
	                             stopBtn.frame.size.width,
	                             stopBtn.frame.size.height);
	[cancelBtn addTarget:self action:@selector(onBtnCancel:) forControlEvents:UIControlEventTouchUpInside];
	self.cancelBtn = cancelBtn;
	[self.view addSubview:cancelBtn];

	//popupView
	self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
	self.popupView.ParentView = self.view;

	//SettingView
	UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithTitle:KCIseSettingBtnTitle
	                                                               style:UIBarButtonItemStylePlain
	                                                              target:self
	                                                              action:@selector(onSetting:)];
	self.navigationItem.rightBarButtonItem = settingBtn;
}



- (void)viewWillAppear:(BOOL)animated {

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

- (void)viewWillDisappear:(BOOL)animated{

    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    [self.iFlySpeechEvaluator cancel];
    self.resultView.text =KCResultNotify1;
    self.resultText=@"";

    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	if (!self.iFlySpeechEvaluator) {
		self.iFlySpeechEvaluator = [IFlySpeechEvaluator sharedInstance];
	}
	self.iFlySpeechEvaluator.delegate = self;
	//清空参数，目的是评测和听写的参数采用相同数据
	[self.iFlySpeechEvaluator setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    self.iseParams=[ISEParams fromUserDefaults];
    [self reloadCategoryText];
}

-(void)reloadCategoryText{
    
    [self.iFlySpeechEvaluator setParameter:self.iseParams.bos forKey:[IFlySpeechConstant VAD_BOS]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.eos forKey:[IFlySpeechConstant VAD_EOS]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.category forKey:[IFlySpeechConstant ISE_CATEGORY]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.language forKey:[IFlySpeechConstant LANGUAGE]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.rstLevel forKey:[IFlySpeechConstant ISE_RESULT_LEVEL]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.timeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    
    if ([self.iseParams.language isEqualToString:KCLanguageZHCN]) {
        if ([self.iseParams.category isEqualToString:KCCategorySyllable]) {
            self.textView.text = LocalizedEvaString(KCTextCNSyllable, nil);
        }
        else if ([self.iseParams.category isEqualToString:KCCategoryWord]) {
            self.textView.text = LocalizedEvaString(KCTextCNWord, nil);
        }
        else {
            self.textView.text = LocalizedEvaString(KCTextCNSentence, nil);
        }
    }
    else {
        if ([self.iseParams.category isEqualToString:KCCategoryWord]) {
            self.textView.text = LocalizedEvaString(KCTextENWord, nil);
        }
        else {
            self.textView.text = LocalizedEvaString(KCTextENSentence, nil);
        }
        self.isValidInput=YES;

    }
}

-(void)resetBtnSatus:(IFlySpeechError *)errorCode{
    
    if(errorCode && errorCode.errorCode!=0){
        self.isSessionResultAppear=NO;
        self.isSessionEnd=YES;
        self.resultView.text =KCResultNotify1;
        self.resultText=@"";
    }else{
        self.isSessionResultAppear=YES;
        self.isSessionEnd=YES;
    }
    self.startBtn.enabled=YES;
}

#pragma mark - keyboard

/*!
 *  隐藏键盘
 *
 *  @param sender textView or resultView
 */
-(void)onKeyBoardDown:(id) sender{
    [self.textView resignFirstResponder];
}


-(void)setViewSize:(BOOL)show Notification:(NSNotification*) notification{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    int keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect textRect = self.textView.frame;
    CGRect resultRect = self.resultView.frame;
    if (show) {
        textRect.size.height = self.view.frame.size.height - keyboardHeight - _DEMO_UI_MARGIN*4;
        resultRect.size.height = 0;
    }
    else{
        textRect.size.height = self.textViewHeight;
        resultRect.size.height = self.resultViewHeight;
    }
    self.textView.frame = textRect;
    self.resultView.frame=resultRect;
    
    [UIView commitAnimations];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    [self setViewSize:YES Notification:notification];
}

-(void)keyboardWillHide :(NSNotification *)notification{
    [self setViewSize:NO Notification:notification ];
}


#pragma mark -
#pragma mark - Button handler

/*!
 *  设置
 *
 *  @param sender settingBtn
 */
- (void)onSetting:(id)sender {
	if (!self.settingViewCtrl) {
		self.settingViewCtrl = [[ISESettingViewController alloc] initWithStyle:UITableViewStylePlain];
		self.settingViewCtrl.delegate = self;
	}

	[self.navigationController pushViewController:self.settingViewCtrl animated:YES];
}

/*!
 *  开始录音
 *
 *  @param sender startBtn
 */
- (void)onBtnStart:(id)sender {
    
	[self.iFlySpeechEvaluator setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
	[self.iFlySpeechEvaluator setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
	[self.iFlySpeechEvaluator setParameter:@"xml" forKey:[IFlySpeechConstant ISE_RESULT_TYPE]];

    [self.iFlySpeechEvaluator setParameter:@"eva.pcm" forKey:[IFlySpeechConstant ISE_AUDIO_PATH]];
    
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSLog(@"text encoding:%@",[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant TEXT_ENCODING]]);
    NSLog(@"language:%@",[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant LANGUAGE]]);
    
    BOOL isUTF8=[[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant TEXT_ENCODING]] isEqualToString:@"utf-8"];
    BOOL isZhCN=[[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant LANGUAGE]] isEqualToString:KCLanguageZHCN];
    
    BOOL needAddTextBom=isUTF8&&isZhCN;
    NSMutableData *buffer = nil;
    if(needAddTextBom){
        if(self.textView.text && [self.textView.text length]>0){
            Byte bomHeader[] = { 0xEF, 0xBB, 0xBF };
            buffer = [NSMutableData dataWithBytes:bomHeader length:sizeof(bomHeader)];
            [buffer appendData:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@" \ncn buffer length: %lu",(unsigned long)[buffer length]);
        }
    }else{
        buffer= [NSMutableData dataWithData:[self.textView.text dataUsingEncoding:encoding]];
        NSLog(@" \nen buffer length: %lu",(unsigned long)[buffer length]);
    }
    self.resultView.text =KCResultNotify2;
    self.resultText=@"";
	[self.iFlySpeechEvaluator startListening:buffer params:nil];
    self.isSessionResultAppear=NO;
    self.isSessionEnd=NO;
    self.startBtn.enabled=NO;
}

/*!
 *  暂停录音
 *
 *  @param sender stopBtn
 */
- (void)onBtnStop:(id)sender {
    
    if(!self.isSessionResultAppear &&  !self.isSessionEnd){
        self.resultView.text =KCResultNotify3;
        self.resultText=@"";
    }
    
	[self.iFlySpeechEvaluator stopListening];
    [self.resultView resignFirstResponder];
    [self.textView resignFirstResponder];
    self.startBtn.enabled=YES;
}

/*!
 *  取消
 *
 *  @param sender cancelBtn
 */
- (void)onBtnCancel:(id)sender {

	[self.iFlySpeechEvaluator cancel];
	[self.resultView resignFirstResponder];
    [self.textView resignFirstResponder];
	[self.popupView removeFromSuperview];
    self.resultView.text =KCResultNotify1;
    self.resultText=@"";
    self.startBtn.enabled=YES;
}


/*!
 *  开始解析
 *
 *  @param sender parseBtn
 */
- (void)onBtnParse:(id)sender {
    
    ISEResultXmlParser* parser=[[ISEResultXmlParser alloc] init];
    parser.delegate=self;
    [parser parserXml:self.resultText];
    
}


#pragma mark - ISESettingDelegate

/*!
 *  设置参数改变
 *
 *  @param params 参数
 */
- (void)onParamsChanged:(ISEParams *)params {
    self.iseParams=params;
    [self performSelectorOnMainThread:@selector(reloadCategoryText) withObject:nil waitUntilDone:NO];
}

#pragma mark - IFlySpeechEvaluatorDelegate
/*!
 *  音量和数据回调
 *
 *  @param volume 音量
 *  @param buffer 音频数据
 */
- (void)onVolumeChanged:(int)volume buffer:(NSData *)buffer {
//    NSLog(@"volume:%d",volume);
    [self.popupView setText:[NSString stringWithFormat:@"音量：%d",volume]];
    [self.view addSubview:self.popupView];
}

/*!
 *  开始录音回调
 *  当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。如果发生错误则回调onError:函数
 */
- (void)onBeginOfSpeech {

}

/*!
 *  停止录音回调
 *    当调用了`stopListening`函数或者引擎内部自动检测到断点，如果没有发生错误则回调此函数。
 *  如果发生错误则回调onError:函数
 */
- (void)onEndOfSpeech {

}

/*!
 *  正在取消
 */
- (void)onCancel {
    
}

/*!
 *  评测结果回调
 *    在进行语音评测过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理.
 *  当errorCode没有错误时，表示此次会话正常结束，否则，表示此次会话有错误发生。特别的当调用
 *  `cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函
 *  数之前如果重新调用了`startListenging`函数则会报错误。
 *
 *  @param errorCode 错误描述类
 */
- (void)onError:(IFlySpeechError *)errorCode {
    if(errorCode && errorCode.errorCode!=0){
        [self.popupView setText:[NSString stringWithFormat:@"错误码：%d %@",[errorCode errorCode],[errorCode errorDesc]]];
        [self.view addSubview:self.popupView];
        
    }
    
    [self performSelectorOnMainThread:@selector(resetBtnSatus:) withObject:errorCode waitUntilDone:NO];

}

/*!
 *  评测结果回调
 *   在评测过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 *
 *  @param results -[out] 评测结果。
 *  @param isLast  -[out] 是否最后一条结果
 */
- (void)onResults:(NSData *)results isLast:(BOOL)isLast{
	if (results) {
		NSString *showText = @"";
        
        const char* chResult=[results bytes];
        
        BOOL isUTF8=[[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant RESULT_ENCODING]]isEqualToString:@"utf-8"];
        NSString* strResults=nil;
        if(isUTF8){
            strResults=[[NSString alloc] initWithBytes:chResult length:[results length] encoding:NSUTF8StringEncoding];
        }else{
            NSLog(@"result encoding: gb2312");
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            strResults=[[NSString alloc] initWithBytes:chResult length:[results length] encoding:encoding];
        }
        if(strResults){
            showText = [showText stringByAppendingString:strResults];
        }
        
        self.resultText=showText;
		self.resultView.text = showText;
        self.isSessionResultAppear=YES;
        self.isSessionEnd=YES;
        if(isLast){
            [self.popupView setText:@"评测结束"];
            [self.view addSubview:self.popupView];
        }

	}
    else{
        if(isLast){
            [self.popupView setText:@"你好像没有说话哦"];
            [self.view addSubview:self.popupView];
        }
        self.isSessionEnd=YES;
    }
    self.startBtn.enabled=YES;
}

#pragma mark - ISEResultXmlParserDelegate

-(void)onISEResultXmlParser:(NSXMLParser *)parser Error:(NSError*)error{
    
}

-(void)onISEResultXmlParserResult:(ISEResult*)result{
    self.resultView.text=[result toString];
}


@end
