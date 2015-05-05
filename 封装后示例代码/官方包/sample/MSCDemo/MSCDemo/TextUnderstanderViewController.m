//
//  TextUnderstanderViewController.m
//  MSCDemo
//
//  Created by AlexHHC on 4/24/14.
//  Copyright (c) 2014 iflytek. All rights reserved.
//

#import "TextUnderstanderViewController.h"
#import "UIPlaceHolderTextView.h"
#import "Definition.h"
#import "PopupView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyTextUnderstander.h"
@interface TextUnderstanderViewController ()

@end

@implementation TextUnderstanderViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
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
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(onClearBtn:)];
   // self.navigationItem.rightBarButtonItem = anotherButton;
    self.clearBtn = anotherButton;
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor whiteColor];
    self.view = mainView;
    self.title = @"文本语义理解";
    int top = Margin*2;
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:
                                         CGRectMake(Margin*2, top, self.view.frame.size.width-Margin*4, mainView.frame.size.height-NavigationBarHeight-70-Margin*4)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
    [self.view addSubview:resultView];
    resultView.font = [UIFont systemFontOfSize:17.0f];
    self.defaultText = @"北京到上海的火车";
    resultView.placeholder = [NSString stringWithFormat:@"你可以输入:\n%@ 【此demo默认】 \n明天下午3点提醒我4点开会\n牛顿第一定律\n1+101+524/(2+38)*85",self.defaultText];
    //键盘
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    resultView.inputAccessoryView = toolbar;
    //[resultView setEditable:NO];
    self.resultView = resultView;
    [self.resultView  setReturnKeyType:UIReturnKeyDone];
    self.resultView .delegate = self;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchBtn setTitle:@"文本理解" forState:UIControlStateNormal];
    searchBtn.frame = CGRectMake(Padding, resultView.frame.size.height + top+ Padding, (self.view.frame.size.width-Padding*2), ButtonHeight);
    [self.view addSubview:searchBtn];
    searchBtn = searchBtn;
    [searchBtn addTarget:self action:@selector(onBtnSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    _popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 100, 0, 0)];
    _popUpView.ParentView = self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _login  = [[DemoLogin alloc]initWithParentView:self.view];
//    if (![DemoLogin isLogin]) {
//        [_login Login];
//    }
    
    //[searchBtnn setEnabled:NO];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * @隐藏键盘
 */
-(void)onKeyBoardDown:(id) sender
{
    [self.resultView  resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Handler
/*
 * @ 语义理解按钮响应函数
 */
- (void) onBtnSearch:(id) sender
{
    [self understand];
}

/*
 * @ 语义理解
 */
-(void) understand
{
    //创建语音配置
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID_VALUE,TIMEOUT_VALUE];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];

    IFlyTextUnderstander * underStand = [[IFlyTextUnderstander alloc]init];
    NSString * text;
    if ([self.resultView.text isEqualToString:@""])
    {
        text  = self.defaultText;
    }
    else
    {
        text =self.resultView.text;
    }
    [underStand understandText:text withCompletionHandler:^(NSString* restult, IFlySpeechError* error)
                          {
                              NSLog(@"result is : %@",restult);
                              self.resultView.text = restult;
                              if (error!=nil && error.errorCode!=0) {
                                  NSString* errorText = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
                                  [self.popUpView setText: errorText];
                                  [self.view addSubview:self.popUpView];
                            }
                              if (self.navigationItem.rightBarButtonItem ==nil) {
                                  self.navigationItem.rightBarButtonItem = self.clearBtn;
                              }
                          }];
}

#pragma mark - TextView Delegate
/*
 * @ 清空文本
 */
- (void) onClearBtn:(id) sender
{
    self.resultView.text = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

/*
 * @ 当文本内容为空时，隐藏清空文本按钮
 */
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text==nil || [textView.text isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem =  nil;
    }
    else
    {
        if (self.navigationItem.rightBarButtonItem ==nil) {
            self.navigationItem.rightBarButtonItem = self.clearBtn;
        }
    }
}

/*
 * @ 当用户在键盘上按下理解按钮时启动
 */
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self understand];
        [self.resultView resignFirstResponder];
        return NO;
    }
    return YES;
}



@end
