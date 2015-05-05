//
//  ISRDataHander.m
//  MSC
//
//  Created by ypzhao on 12-11-19.
//  Copyright (c) 2012年 iflytek. All rights reserved.
//

#import "ISRDataHelper.h"
#import "SBJson4.h"

static ISRDataHelper *ISRdataHander = nil;
@implementation ISRDataHelper

+ (id) shareInstance
{
    if (!ISRdataHander) {
        ISRdataHander = [[ISRDataHelper alloc] init];
    }
    return ISRdataHander;
}


// 将服务器端返回的原始值返回
- (NSDictionary*) getResultFromString:(const char *)params
{
    if (params == NULL) {
        return nil;
    }
    NSString *result = [[NSString alloc ]initWithCString: params encoding:NSUTF8StringEncoding];
    
    if (result == nil) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *otherResult = [[NSString alloc ]initWithCString: params encoding:enc];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"100",otherResult,nil];
        return dictionary;
    }
    else {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"100",result,nil];
        return dictionary;        
    }
}


//  解析asr返回的结果
- (NSString*) getResultFormAsr:(NSString*)params
{
//    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
//   	if(!params || strlen(params) == 0 || strstr(params,"nomatch"))
//	{
//		return dic;
//	}
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSString *inputString = nil;
    
//	NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//	NSString *str = [NSString stringWithCString:params encoding:enc];
    
//    NSString *str = [[[NSString alloc ]initWithCString: params encoding:NSUTF8StringEncoding] autorelease];
    
	NSArray *array = [params componentsSeparatedByString:@"\n"];

	for (int  index = 0; index < array.count; index++)
	{
        NSRange range;
		NSString *line = [array objectAtIndex:index];
		
        //		NSString *contact = @"";
		NSRange idRange = [line rangeOfString:@"id="];
        NSRange nameRange = [line rangeOfString:@"name="];
		NSRange confidenceRange = [line rangeOfString:@"confidence="];
		NSRange grammarRange = [line rangeOfString:@" grammar="];
        
        NSRange inputRange = [line rangeOfString:@"input="];
        
		if (confidenceRange.length == 0 || grammarRange.length == 0 || inputRange.length == 0 )
		{
			continue;
		}
        
        //check nomatch
        if (idRange.length!=0) {
            NSUInteger idPosX = idRange.location + idRange.length;
            NSUInteger idLength = nameRange.location - idPosX;
            range = NSMakeRange(idPosX,idLength);
            NSString *idValue = [[line substringWithRange:range]
                                 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            if ([idValue isEqualToString:@"nomatch"]) {
                return @"";
            }
        }
      
		
        //Get Confidence Value
        NSUInteger confidencePosX = confidenceRange.location + confidenceRange.length;
        NSUInteger confidenceLength = grammarRange.location - confidencePosX;
        range = NSMakeRange(confidencePosX,confidenceLength);
        
        
        NSString *score = [line substringWithRange:range];
        
        NSUInteger inputStringPosX = inputRange.location + inputRange.length;
        NSUInteger inputStringLength = line.length - inputStringPosX;
        
        range = NSMakeRange(inputStringPosX , inputStringLength);
        inputString = [line substringWithRange:range];
       // [dic setObject:score forKey:inputString];
        [resultString appendFormat:@"%@ 置信度%@\n",inputString, score];
	}
	
    return resultString;

}

// 解析json格式的数据
//{"sn":1,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"w":"白日","sc":0}]},{"bg":0,"cw":[{"w":"依山","sc":0}]},{"bg":0,"cw":[{"w":"尽","sc":0}]},{"bg":0,"cw":[{"w":"黄河入海流","sc":0}]},{"bg":0,"cw":[{"w":"。","sc":0}]}]}
//{"sn":1,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"sc":"73","gm":"0","w":"北京到合肥"},{"sc":"63","gm":"0","w":"天京到合肥"},{"sc":"57","gm":"0","w":"南京到合肥"}]}]}
-(NSString *) getResultFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];

    //返回的格式必须为utf8的,否则发生未知错误
    //NSString *jsonString = [NSString stringWithCString:params encoding:NSUTF8StringEncoding];
    NSString *jsonString = params;
    NSArray *jsonArray = [jsonString componentsSeparatedByString:@"\n"];
    
    for (int index = 0; index < [jsonArray count]; index++) {
           }
    
    id block = ^(id obj, BOOL *ignored) {
        NSDictionary *dic = obj;
        
        NSArray *wordArray = [dic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }

    };
    
    id eh = ^(NSError *err) {
        NSLog(@"json parser error");
        //        self.output.string = err.description;
    };
    id parser = [SBJson4Parser parserWithBlock:block allowMultiRoot:NO unwrapRootArray:NO errorHandler:eh];
    [parser parse:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
   
    return tempStr;
}

-(NSString *) getResultFromASRJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    
    //返回的格式必须为utf8的,否则发生未知错误
    //NSString *jsonString = [NSString stringWithCString:params encoding:NSUTF8StringEncoding];
    NSString *jsonString = params;
    
    id block = ^(id obj, BOOL *ignored) {
        NSDictionary *dic = obj;
        
        NSArray *wordArray = [dic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                NSString *score = [wDic objectForKey:@"sc"];
                [tempStr appendString: str];
                [tempStr appendFormat:@" 置信度:%@",score];
                [tempStr appendString: @"\n"];
            }
        }
        
    };
    
    id eh = ^(NSError *err) {
        NSLog(@"json parser error");
        //        self.output.string = err.description;
    };
    id parser = [SBJson4Parser parserWithBlock:block allowMultiRoot:NO unwrapRootArray:NO errorHandler:eh];
    [parser parse:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return tempStr;
}
@end
