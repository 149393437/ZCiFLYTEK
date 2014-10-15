ZCiFLYTEK
=========

封装了讯飞语音识别
//版本说明 iOS研究院 305044955
//zc封装语音识别1.0版本
/*
 需要添加系统的库
 AdSupport
 AddressBook
 QuartzCore
 SystemCOnfiguration
 AudioToolBox
 libz
 讯飞提供的库
 iflyMSC.frameWork
 
 代码示例
 //读取
 ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
 [xunfei playStart:@"我是最帅的"];

 
 //识别
 ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
 [xunfei discernBlock:^(NSString *a) {
 NSLog(@"识别出来的结果~%@",a);
 }];

