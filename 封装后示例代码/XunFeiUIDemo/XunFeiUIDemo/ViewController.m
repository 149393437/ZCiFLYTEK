//
//  ViewController.m
//  XunFeiUIDemo
//
//  Created by 张诚 on 15/5/5.
//  Copyright (c) 2015年 zhangcheng. All rights reserved.
//

#import "ViewController.h"
#import "ZCiFLYTEK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //读  识别
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor=[UIColor redColor];
    [button setTitle:@"读取" forState:UIControlStateNormal];
    button.frame=CGRectMake(0, 100, 100, 100);
    [self.view addSubview:button];
    
    
    UIButton*button1=[UIButton buttonWithType:UIButtonTypeCustom];
    button1.backgroundColor=[UIColor greenColor];
    [button1 setTitle:@"识别" forState:UIControlStateNormal];
    button1.frame=CGRectMake(200, 100, 100, 100);
    [self.view addSubview:button1];
    
    [button addTarget:self action:@selector(read) forControlEvents:UIControlEventTouchUpInside];
    [button1 addTarget:self action:@selector(recognition) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)read{
    //读取
    ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
    [xunfei playStart:@"讯飞是最好的"];
}
-(void)recognition{
    //识别
    ZCiFLYTEK*xunfei=[ZCiFLYTEK shareManager];
    [xunfei discernShowView:nil Block:^(NSString *xx) {
        NSLog(@"~~~%@",xx);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
