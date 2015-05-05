//
//  ISRDataHander.h
//  MSC
//
//  Created by ypzhao on 12-11-19.
//  Copyright (c) 2012年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "EngineDefine.pch"

//#import "IFlySetting.h"

// 处理服务器返回的数据
@protocol ISRDataHelper<NSObject>

//- (NSString*) dataHander:(NSString *)params parse:(ParseCategory) isParse;
- (NSString *) getResultFromJson:(NSString*)params;
- (NSString*) getResultFormAsr:(NSString*)params;
-(NSString *) getResultFromASRJson:(NSString*)params;

@end

@interface ISRDataHelper : NSObject<ISRDataHelper>


+ (id) shareInstance;

@end
