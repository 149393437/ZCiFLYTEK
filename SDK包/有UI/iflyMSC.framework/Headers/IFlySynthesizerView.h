//
//  IFlySynthesizerView.h
//  MSC
//
//  Created by iflytek on 13-4-17.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFlySynthesizerViewDelegate.h"

@class IFlySynthesizerViewImp;

/** 语音合成类 */

@interface IFlySynthesizerView : UIView
{
    IFlySynthesizerViewImp      *_iFlySynthesizerViewImp;
    id<IFlySynthesizerViewDelegate> _delegate;
}

/** 设置委托对象 */
@property (assign) id<IFlySynthesizerViewDelegate> delegate;

/** 初始化合成控件
 
 params的参数取值如下:
 
 1. appid:应用程序ID (必选)
 2. timeout:网络超时时间,单位:ms,默认为20000,范围0-30000 (可选)
 3. usr:用户名,开发者在开发者网站上注册的用户名
 4. pwd:用户密码,开发者在开发者网站上的用户密码
 5. server_url:默认连接语音云公网入口 http://dev.voicecloud.cn/index.htm,只有特定业务才需要设 置为固定ip或域名,普通开发者不需要设置
 6. besturl_search:默认为1,如果server_url设置为固定ip地址, 需要将此参数设置为0,表示不寻找最佳服务器。如果 server_url为域名,可以将此参数设置为1

 @param origin 控件的坐标，左上角的坐标
 @param params 初始化的参数
 */
- (id) initWithOrigin:(CGPoint) origin params:(NSString *) params;

/** 设置合成参数
 
 设置参数需要在调用startSpeaking:之前进行。
 
 参数的名称和取值:
 
 1. speed:合成语速,取值范围 0~100
 2. volume:合成的音量,取值范围 0~100
 3. voice_name;默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
 4. sample_rate:目前支持的采样率有 16000 和 8000;
 5. params:扩展参数
 
 @param key  合成参数
 @param value 参数取值
 @return 设置成功返回YES，失败返回NO
 */
-(BOOL) setParameter:(NSString *)key  value:(NSString *) value;

/** 开始语音合成
 
 @param text 合成的文本
 */
- (void)startSpeaking:(NSString *)text;

@end
