//
//  ViewController.m
//  多表查询
//
//  Created by zhangyongjun on 16/10/25.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //将stuid作为外键
    @"SELECT * FROM t_stu, t_aa where t_stu.id = t_aa.stuid";
    
    //别名
    @"SELECT COUNT(*) AS number FROM t_stu";
    @"SELECT ts.id FROM t_stu AS ts where ts.name = 'lisi'";
}


@end
