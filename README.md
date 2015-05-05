ZCiFLYTEK
=========

//版本说明 iOS研究院 305044955
//ZC封装语音识别2.0版本
//支持64位，改变了UI，更加好看 把UI的SDK和不带UI的SDK合并了
//ZC封装语音识别1.0版本
//进行了讯飞的初始封装
/*
需要添加系统的库
AdSupport
AddressBook
QuartzCore
SystemConfiguration
AudioToolBox
libz
CoreTelephony
AVFoundation
讯飞提供的库
iflyMSC.frameWork

代码示例
//读取
ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
[xunfei playStart:@"我是最帅的"];

//识别带UI界面的
ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
[xunfei discernShowView:self.view Block:^(NSString *xx) {
NSLog(@"识别结果~~~%@",xx);
}];

//识别不带UI界面的
ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
[xunfei discernShowView:nil Block:^(NSString *xx) {
NSLog(@"识别结果~~~%@",xx);
}];
*/

