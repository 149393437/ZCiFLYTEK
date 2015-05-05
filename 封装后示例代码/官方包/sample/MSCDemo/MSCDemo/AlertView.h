//
//  AlertView.h
//  MSCDemo
//
//  Created by hchuang on 13-9-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertView : UIView
{
    UILabel         *_textLabel;
    int             _queueCount;
    UIActivityIndicatorView *_aiv;
}
@property (strong) UIView*  ParentView;
- (void) setText:(NSString *) text;
-(void) dismissModalView;
@end
