//
//  ViewController.m
//  DML语句
//
//  Created by zhangyongjun on 16/10/23.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //插入
    NSString *insert = @"INSERT INTO t_student(name, age, score) VALUES ('zhangsan', 12, 88)";
    
    //更新
    NSString *update = @"UPDATE t_student SET age = 20, name = 'lisi'";
    
    //删除
    NSString *delete = @"DELETE FROM t_student";
    
    //条件语句
    //@"WHERE name = 'lisi'"
    //@"WHERE name IS 'lisi'"
    //@"WHERE name != 'lisi'"
    //@"WHERE name IS NOT 'lisi'"
    //@"WHERE age > 18"
    //@"WHERE name IS 'lisi' AND age > 18"
    //@"WHERE name IS 'lisi' OR age > 18"
}


@end
