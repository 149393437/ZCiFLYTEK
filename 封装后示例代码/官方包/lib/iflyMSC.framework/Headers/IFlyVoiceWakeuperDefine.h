//
//  IFlyVoiceWakeuperDefine.h
//  wakeup
//
//  Created by admin on 14-3-29.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 服务设置参数
 * sst=wake表示唤醒
 * sst=enroll表示注册
 */
#define     STR_SESSION_TYPE            @"sst"     //服务类型
#define     SESSION_TYPE                @"sst="    //服务类型

#define     STR_WAKEUP                  @"wake"             //唤醒
#define     STR_ENROLL                  @"enroll"           //注册


/**
* 唤醒时，表示资源对应的阀值，为输入值，参数类型为：ID:20;20;3
*      已ID为起始，中间用“;”隔开，表示公三个资源，各自阀值对应为20，20和3
 */
#define     STR_IVW_THRESHOLD           @"ivw_threshold"    //唤醒词对应的门限

/**
 * 传入参数
 * 主要是没有定义的参数，依赖params传入
 */
#define     STR_PARAM                   @"params"

/**
 * 训练，合并生成的资源路径
 * 例：ivw_word_path=/abc/123/newpath.irf
 */
#define     IVW_WORD_PATH               @"ivw_word_path"
#define     STR_IVW_WORD_PATH           @"ivw_word_path"    //训练合并生成后的资源路径列表

/**
 * 唤醒，合并所使用的资源列表
 * 格式：资源路径；路径之间使用“；”隔开
 * 例：ivw_wake_list = /abc/123/path1.irf;/abc/123/path2.irf;
 */
#define     IVW_WAKE_LIST               @"ivw_wake_list="   //唤醒，合并的资源文件路径列表
#define     STR_IVW_WAKE_LIST           @"ivw_wake_list"

/**
 * 业务成功后的会话持续状态
 * keep_alive 0:唤醒一次就结束，1：唤醒后继续
 */
#define     STR_KEEP_ALIVE              @"keep_alive"

/**
 * focus_type注册和唤醒的返回参数
 * wake 唤醒
 * enroll 注册
 */
#define     STR_FOCUS_TYPE              @"focus_type"       //服务类型

/**
 * 服务状态
 * status=success 服务正常
 * status=failed 服务失败
 * status=done 注册完成
 */
#define     STR_STATUS                  @"status"     //服务状态
#define     STR_SUCESS                  @"success"   //服务成功
#define     STR_FAILED                  @"failed"   //服务失败
#define     STR_DONE                    @"done"     //训练完成

/**
 * 唤醒结果的位置
 *
 */
#define     STR_ID                      @"id"     //唤醒结果的id

/**
 * 唤醒资源的阀值
 * 注册时返回，表示注册资源对应的阀值，为输出值
 */
#define     STR_THRESHOLD               @"threshold"  //训练资源的阀值

/**
 * 服务结果的可信度
 */
#define     STR_SCORE                   @"score"  //服务结果可信度

/**
 * 为注册时返回，表示已经注册成功的次数
 */
#define     STR_NUM                     @"num"     //已训练成功次数

/**
 * 表示服务传入音频对应的起始点和结束点
 */
#define     STR_BOS                     @"bos"     //前端点
#define     STR_EOS                     @"eos"     //后端点

/**
 *录音方式，如果是外部数据，设置为-1，通过WriteAudio送入音频
 *注意：目前紧紧支持唤醒服务，注册业务尚不支持
 */
#define     STR_AUDIO_SOURCE            @"audio_source"


/**
 * 表示资源合并操作
 */
#define MERGE_RES_ACTION @"merge"