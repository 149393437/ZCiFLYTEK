//
//  DataDownloader.h
//  msc
//
//  Created by ypzhao on 13-3-3.
//  Copyright (c) 2013年 IFLYTEK. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IFlyDataDownloaderDelegate

/** 数据下载回调
 
 @param result -[out] 下载的数据
 @param endCode -[out] 错误码
 */
- (void) onIFlyDataDownloadEnd:(NSString *)result endCode:(int) endCode;

@end

@interface IFlyDataDownloader : NSObject
{
    int endCode;
}

/** 开始数据下载

 @param params 下载时，上传的参数
 */
- (void) dataDownLoader:(NSString *) params;

/** 设置委托对象 */
@property (assign) id<IFlyDataDownloaderDelegate> delegate;

@end
