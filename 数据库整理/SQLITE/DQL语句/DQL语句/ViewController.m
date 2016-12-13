//
//  ViewController.m
//  DQL语句
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
    
    //查询
    @"SELECT name, age FROM t_stu"
    @"SELECT * FROM t_stu"
    
    //统计（如果指定了字段，则只统计该字段不为空的数据）
    //count(), avg(), sum(), max(), min()
    @"SELECT COUNT(*) FROM t_stu"
    @"SELECT AVG(age) FROM t_stu"
    
    //排序(先按照age降序，如果age有相同，按照score升序)
    @"SELECT * FROM t_stu ORDER BY age DESC, score ASC"//默认升序ASC
    
    //分页(跳过0条，取5条)
    @"SELECT * FROM t_stu LIMIT 0, 5"
    //前5条
    @"SELECT * FROM t_stu LIMIT 5"
}


@end
