//
//  ViewController.m
//  FMDB_use
//
//  Created by zhangyongjun on 16/12/11.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"

@interface Student : NSObject <NSCoding>

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *sex;

@property (assign, nonatomic) int age;
@property (assign, nonatomic) double score;

@end

@implementation Student

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.sex = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"sex"];
        self.age = [aDecoder decodeIntForKey:@"age"];
        self.score = [aDecoder decodeDoubleForKey:@"score"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeInt:self.age forKey:@"age"];
    [aCoder encodeDouble:self.score forKey:@"score"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name: %@, age: %d, score: %f, sex: %@", self.name, self.age, self.score, self.sex];
}

@end


@interface ViewController ()

@property (strong, nonatomic) FMDatabase *database;

@property (strong, nonatomic) FMDatabaseQueue *databaseQueue;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createAndOpenDatabase];
    [self createTable];
}

- (void)createAndOpenDatabase {
    NSString *path = @"/Users/ddn/Desktop/My Github/sqlite-fmdb_summary/数据库整理/SQLITE/FMDB_use/tmp.sqlite";
    
    //1.如果文件不存在则创建
    //2.如果path==@"",则会创建一个临时的数据库在硬盘上，断开连接后自动删除
    //3.如果path==null,则会在内存中创建一个临时的数据库，断开连接后会自动删除
    _database = [FMDatabase databaseWithPath:path];
    
    
}

- (void)createTable {
    
    if (![_database open])
        return NSLog(@"打开数据库失败：%@", [_database lastErrorMessage]);
    
//    [_database beginTransaction];
//    
//    BOOL create = [_database executeUpdate:@"create table if not exists t_stu (id integer primary key autoincrement, name text, age integer, score real, sex text)"];
//    BOOL create2 = [_database executeUpdate:@"create table if not exists t_student (id integer primary key autoincrement, student blob)"];
//    
//    if (create && create2) {
//        [_database commit];
//    } else {
//        [_database rollback];
//    }
    
    //多条sql
    NSString *sql = @"create table if not exists t_stu (id integer primary key autoincrement, name text, age integer, score real, sex text);create table if not exists t_student (id integer primary key autoincrement, student blob);";
//    BOOL create = [_database executeStatements:sql];
    BOOL create = [_database executeStatements:sql withResultBlock:^int(NSDictionary *resultsDictionary) {
        NSLog(@"resultsDictionary: %@", resultsDictionary);
        return 0;//0代表继续执行下一条
    }];
    if (!create) {
        NSLog(@"执行Statements失败：%@", [_database lastErrorMessage]);
    }
    
    if (![_database close])
        return NSLog(@"关闭数据库失败:%@", [_database lastErrorMessage]);
}

- (IBAction)insert:(id)sender {
    if (![_database open])
        return NSLog(@"打开数据库失败：%@", [_database lastErrorMessage]);
    
    //- (BOOL)executeUpdate:(NSString*)sql, ...;参数是对象类型
    
    [_database beginTransaction];
    
    int i = 10000;
    while (i > 0) {
        i --;
        BOOL insert = [_database executeUpdate:@"insert into t_stu (name, age, score, sex) values(?, ?, ?, ?)", _nameTextField.text, @(_ageTextField.text.integerValue), @(_scoreTextField.text.floatValue), _sexTextField.text];
        
        Student *student = [Student new];
        student.name = _nameTextField.text;
        student.sex = _sexTextField.text;
        student.age = _ageTextField.text.intValue;
        student.score = _scoreTextField.text.doubleValue;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:student];
        
        BOOL insert2 = [_database executeUpdate:@"insert into t_student (student) values(?)", data];
        
        if (!(insert && insert2)) break;
    }
    
    if (i == 0) {
        [_database commit];
    } else {
        [_database rollback];
    }
    
//    - (BOOL)executeUpdateWithFormat:(NSString *)format, ...;
    
//    BOOL insert = [_database executeUpdateWithFormat:@"insert into t_stu (name, age, score, sex) values(%@, %d, %f, %@)", _nameTextField.text, _ageTextField.text.intValue, _scoreTextField.text.doubleValue, _sexTextField.text];
    
    
//    - (BOOL)executeUpdate:(NSString*)sql values:(NSArray *)values error:(NSError * __autoreleasing *)error;
    
//    NSError *error;
//    BOOL insert = [_database executeUpdate:@"insert into t_stu (name, age, score, sex) values(?, ?, ?, ?)" values:@[_nameTextField.text, @(_ageTextField.text.integerValue), @(_scoreTextField.text.floatValue), _sexTextField.text] error:&error];
    
    
    //- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
    
//    BOOL insert = [_database executeUpdate:@"insert into t_stu (name, age, score, sex) values(?, ?, ?, ?)" withArgumentsInArray:@[_nameTextField.text, @(_ageTextField.text.integerValue), @(_scoreTextField.text.floatValue), _sexTextField.text]];
    
    
    //- (BOOL)executeUpdate:(NSString*)sql withErrorAndBindings:(NSError**)outErr, ...;
    
//    NSError *error;
//    BOOL insert = [_database executeUpdate:@"insert into t_stu (name, age, score, sex) values(?, ?, ?, ?)" withErrorAndBindings:&error, _nameTextField.text, @(_ageTextField.text.integerValue), @(_scoreTextField.text.floatValue), _sexTextField.text];
    
    
    //- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments
    
//    NSDictionary *params = @{@"name": _nameTextField.text, @"age": @(_ageTextField.text.intValue), @"score": @(_scoreTextField.text.doubleValue), @"sex": _sexTextField.text};
//    BOOL insert = [_database executeUpdate:@"insert into t_stu (name, age, score, sex) values(:name, :age, :score, :sex)" withParameterDictionary:params];
    
//    if (!insert)
//        return NSLog(@"插入数据库失败");
    
    if (![_database close])
        return NSLog(@"关闭数据库失败:%@", [_database lastErrorMessage]);
}

- (IBAction)query {
    if (![_database open])
        return NSLog(@"打开数据库失败：%@", [_database lastErrorMessage]);
    
    FMResultSet *set = [_database executeQuery:@"select * from t_stu where score > ? order by score asc", @80];
//    while (set.next) {
//        NSString *name = [set stringForColumn:@"name"];
//        int age = [set intForColumn:@"age"];
//        double score = [set doubleForColumn:@"score"];
//        NSString *sex = [set stringForColumn:@"sex"];
//        
//        NSLog(@"name:%@, age:%d, score:%f, sex:%@", name, age, score, sex);
//    }
    
    while (set.next) {
        NSLog(@"resultDictionary: %@", [set resultDictionary]);
    }
    
    FMResultSet *set2 = [_database executeQuery:@"select * from t_student"];
    while (set2.next) {
        NSData *data = [set2 dataForColumn:@"student"];
        Student *student = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"student:%@", student.description);
    }
    
    if (![_database close])
        return NSLog(@"关闭数据库失败:%@", [_database lastErrorMessage]);
}

- (IBAction)queue {
#warning queue是串行队列，执行顺序会按照任务的添加顺序执行，但是数据库不会出现并发操作，所以放到queue中是安全的
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:@"/Users/ddn/Desktop/My Github/sqlite-fmdb_summary/数据库整理/SQLITE/FMDB_use/tmp.sqlite"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"update t_stu set age = ?, sex = 'female'", @24];
        }];
    });
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"update t_stu set age = ?, sex = 'female'", @23];
        }];
    });
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *set = [db executeQuery:@"select * from t_stu"];
            int i = 0;
            while (set.next) {
                i ++;
                NSLog(@"%@", set.resultDictionary);
            }
            NSLog(@"%d",i);
        }];
    });
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"update t_stu set age = ?, sex = 'female'", @18];
        }];
    });
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL update1 = [db executeUpdate:@"update t_stu set age = ?", @20];
            BOOL update2 = [db executeUpdate:@"update t_stu set age = ?, sex = 'female'", @19];
            *rollback = !(update1 && update2);
            NSLog(@"%d", *rollback);
        }];
    });
}

@end















