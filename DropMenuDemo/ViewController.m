//
//  ViewController.m
//  DropMenuDemo
//
//  Created by 栾美娜 on 2017/1/5.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import "ViewController.h"
#import "MNDropView.h"
#import "DropModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray * regionArray =@[@"不限",@"嘉定区",@"浦东新区",@"金山区"];
    NSArray *classTypeArray=@[@"短期",@"长期"];
    NSArray *sortRuleArray=@[@"价格",@"评分",@"最新",@"最热"];
    NSMutableArray *list = [NSMutableArray arrayWithObjects:regionArray, classTypeArray , sortRuleArray, nil];
    
    
    MNDropView *menu = [[MNDropView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 40) title:@[@"one", @"two", @"three"] dataArray:list.copy];
    menu.selectEvent = ^ (DropModel *model) {
        NSLog(@"选中了%@",model.text);
    };
    [self.view addSubview:menu];
    
    NSLog(@"哈哈");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
