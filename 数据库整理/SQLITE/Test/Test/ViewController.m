//
//  ViewController.m
//  Test
//
//  Created by zhangyongjun on 16/11/30.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "ViewController.h"
#import "sqlite3.h"

@interface ViewController ()

{
    sqlite3 *db;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (sqlite3_open("/Users/zhangyongjun/Desktop/数据库整理/SQLITE/Test/test.sqlite", &db) == SQLITE_OK) {
        NSLog(@"success");
    }
    
}

//两种方案，相对绑定效率略高，但是都会每执行一次都会开启事务，提交事务，如果统一手动开启并提交会提高效率(大批量数据)，另外事务内的操作会统一执行，或者统一不执行，如果执行的多条语句间有依赖关系，应该放到一个事务里去执行,如果都成功则提交，否则回滚（即都执行成功，或都执行失败）
- (IBAction)add:(id)sender {
    NSString *name = @"zhangsan";
    NSInteger age = 15;
    NSString *card = @"34389586234";
    NSInteger score = 80;
    
    //开启事务
    char *beginTransaction = "begin transaction";
    char *error;
    if (sqlite3_exec(db, beginTransaction, NULL, NULL, &error) == SQLITE_OK){
        NSLog(@"开启事务成功");
    }
    
    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
    
    NSInteger count = 10000;
    while (count > 0) {
        NSString *insert0 = [NSString stringWithFormat:@"insert into t_stu(name, age, card, score) values ('%@', %zd, '%@', %zd)", name, age, card, score];
        
        char *error;
        if (sqlite3_exec(db, insert0.UTF8String, NULL, NULL, &error) == SQLITE_OK){
//            NSLog(@"success");
        }
        if (error) {
            NSLog(@"%s",error);
        }
        count --;
    }
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"非绑定执行时间:%f",end - begin);
    
    
    //绑定执行
    
    CFAbsoluteTime begin2 = CFAbsoluteTimeGetCurrent();
    
    NSInteger count2 = 10000;
    
    //1.创建准备语句
    char *insert = "insert into t_stu(name, age, card, score) values (?, ?, ?, ?)";
    sqlite3_stmt *stmt;
    //-1 自动计算取出字符串的长度（全部）
    //stmt 准备语句
    //NULL 根据取出的长度后剩余的字符串，这里不需要
    if (sqlite3_prepare_v2(db, insert, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"预处理失败");
        return;
    }
    while (count2 > 0) {
        //2.绑定参数
        //stmt 准备语句
        //1 索引（第几个？,从1开始）
        //name.UTF8String 绑定的值
        //-1 截取绑定值的长度
        //处理方式SQLITE_TRANSIENT（会对参数进行引用）  SQLITE_STATIC（将参数作为一个常量，不会被释放，不做引用）
        sqlite3_bind_text(stmt, 1, name.UTF8String, -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_int64(stmt, 2, age);
        sqlite3_bind_text(stmt, 3, card.UTF8String, -1, SQLITE_TRANSIENT);
        sqlite3_bind_int64(stmt, 4, score);
        
        //3.执行准备语句
        if (sqlite3_step(stmt) == SQLITE_DONE) {
//            NSLog(@"success");
        }
        
        //4.重置语句(针对执行多条，循环2，3，4步即可)
        sqlite3_reset(stmt);
        count2 --;
    }
    
    //5.释放准备语句
    sqlite3_finalize(stmt);
    
    CFAbsoluteTime end2 = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"绑定执行时间:%f", end2 - begin2);
    
    //提交事务
    char *commit = "commit transaction";//或者"ROLLBACK TRANSACTION"取消事务
    if (sqlite3_exec(db, commit, NULL, NULL, &error) == SQLITE_OK){
        NSLog(@"提交事务成功");
    }
}
- (IBAction)delete:(id)sender {
    NSString *delete = [NSString stringWithFormat:@"delete from t_stu where age=%zd",25];
    char *error;
    if (sqlite3_exec(db, delete.UTF8String, nil, nil, &error) == SQLITE_OK) {
        NSLog(@"success");
    } else {
        NSLog(@"error: %s", error);
    }
}
- (IBAction)update:(id)sender {
    
    //开启事务
    char *beginTransaction = "begin transaction";
    char *error;
    if (sqlite3_exec(db, beginTransaction, NULL, NULL, &error) == SQLITE_OK){
        NSLog(@"开启事务成功");
    } else {NSLog(@"error: %s", error);}
    
    NSString *update = [NSString stringWithFormat:@"update t_stu set age=%zd",25];
    if (sqlite3_exec(db, update.UTF8String, nil, nil, &error) == SQLITE_OK) {
        NSLog(@"success");
    } else {
        NSLog(@"error: %s", error);
    }
    
    NSString *update2 = [NSString stringWithFormat:@"update t_stu set arg=%zd",25];
    if (sqlite3_exec(db, update2.UTF8String, nil, nil, &error) == SQLITE_OK) {
        NSLog(@"success");
    } else {
        NSLog(@"error: %s", error);
    }
    
    if (error) {
        //回滚事务
        char *rollback = "ROLLBACK TRANSACTION";//或者"ROLLBACK TRANSACTION"取消事务
        if (sqlite3_exec(db, rollback, NULL, NULL, &error) == SQLITE_OK){
            NSLog(@"回滚事务成功");
        }
    } else {
        //提交事务
        char *commit = "commit transaction";//或者"ROLLBACK TRANSACTION"取消事务
        if (sqlite3_exec(db, commit, NULL, NULL, &error) == SQLITE_OK){
            NSLog(@"提交事务成功");
        }
    }
    
}

//obj是exec语句中的第四个参数， columnCount为列的个数， values为保存值的数组，valueNmaes为列名数组
int callback(void *obj, int columnCount, char **values, char **valueNames) {
    for (int i = 0; i < columnCount; i ++) {
        char *name = valueNames[i];
        char *value = values[i];
        
        NSLog(@"%s, %s", name, value);
    }
    return 0;
}
- (IBAction)query:(id)sender {
    NSString *query = [NSString stringWithFormat:@"select * from t_stu where name='%@' order by age desc limit 0, 5",@"zhangsan"];
    char *error;
    if (sqlite3_exec(db, query.UTF8String, &callback, nil, &error) == SQLITE_ABORT) {
        NSLog(@"success");
    }
    
    
    char *queryStmt = "select * from t_stu limit 5";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, queryStmt, -1, &stmt, nil) != SQLITE_OK) {
        NSLog(@"预处理失败");
    }
    
    //绑定可省略
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int columnCount = sqlite3_column_count(stmt);
        for (int i = 0; i < columnCount; i ++) {
            const char *columnName = sqlite3_column_name(stmt, i);
            NSLog(@"name: %s", columnName);
            int type = sqlite3_column_type(stmt, i);
            switch (type) {
                case SQLITE_TEXT:
                {
                    const unsigned char *value = sqlite3_column_text(stmt, i);
                    NSLog(@"value: %s", value);
                    break;
                }
                case SQLITE_FLOAT:
                {
                    double value = sqlite3_column_double(stmt, i);
                    NSLog(@"value: %f", value);
                    break;
                }
                case SQLITE_INTEGER:
                {
                    int value = sqlite3_column_int(stmt, i);
                    NSLog(@"value: %d", value);
                    break;
                }
                case SQLITE_BLOB:
                {
                    const void *value = sqlite3_column_blob(stmt, i);
                    NSLog(@"value: %@", value);
                    break;
                }
                case SQLITE_NULL:
                {
                    NSLog(@"value: null");
                    break;
                }
                    
                default:
                    NSLog(@"default");
                    break;
            }
        }
    }
    
    //重置可省略
    
    sqlite3_finalize(stmt);
}
- (IBAction)rename:(id)sender {
    NSString *rename = @"alter table t_student rename to t_stu";
    char *error;
    if (sqlite3_exec(db, rename.UTF8String, nil, nil, &error) == SQLITE_OK) {
        NSLog(@"success");
    } else {
        NSLog(@"error: %s", error);
    }
}
- (IBAction)addProperty:(id)sender {
    NSString *addPro = @"alter table t_stu add column sex text";
    char *error;
    if (sqlite3_exec(db, addPro.UTF8String, nil, nil, &error) == SQLITE_OK) {
        NSLog(@"success");
    } else {
        NSLog(@"error: %s", error);
    }
}
- (IBAction)createTable:(id)sender {
    
    char *create = "CREATE TABLE IF NOT EXISTS t_stu(id integer primary key autoincrement, name text not null, age integer default 18, card text, score real not null)";
    char *error;
    if (sqlite3_exec(db, create, NULL, NULL, &error) == SQLITE_OK){
        NSLog(@"success");
    }
}
- (IBAction)deleteTable:(id)sender {
    char *drop = "drop table if exists t_stu";
    char *error;
    if (sqlite3_exec(db, drop, NULL, NULL, &error) == SQLITE_OK){
        NSLog(@"success");
    }

}


@end
