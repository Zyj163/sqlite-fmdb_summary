//
//  ViewController.m
//  DDL语句
//
//  Created by zhangyongjun on 16/10/23.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "ViewController.h"
#import "sqlite3.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //连接数据库，如果没有则创建后打开
    sqlite3 *db = nil;
    if (sqlite3_open("/demo.sqlite", &db) == SQLITE_OK) {
        NSLog(@"success");
    }
    
    //新建表
    char *create = "CREATE TABLE IF NOT EXISTS t_student(id integer primary key, name text, age integer)";
    char *error;
    if (sqlite3_exec(db, create, nil, nil, &error) == SQLITE_OK){
        NSLog(@"sucess");
    }
    
    //删除表
    char *drop = "DROP TABLE IF EXISTS t_student";
    
    //只能实现ALTER的部分功能
    //修改表名(不能删除一列，修改一个已经存在的列名)
    char *rename = "ALTER TABLE t_student RENAME TO student";
    
    //增加属性
    char *addPro = "ALTER TABLE t_student ADD COLUMN sex text";
    
    
    //约束
    //不能为空 NOT NULL
    
    //不能重复 UNIQUE
    
    //默认值 DEFAULT ..
    
    //主键 NOT NULL PRIMARY KEY AUTOINCREMENT
    
    char *newCreate = "CREATE TABLE IF NOT EXISTS t_stu(id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer DEFAULT 18, score real UNIQUE)";
}


@end
