//
//  FileViewController.m
//  SMB_Link_Demo
//
//  Created by JimHuang on 2018/7/4.
//  Copyright © 2018年 jim. All rights reserved.
//

#import "FileViewController.h"
#import <TOSMBClient.h>
#import "DemoDataManager.h"
#import <YYCategories.h>
#import "PlayerViewController.h"

@interface FileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray <TOSMBSessionFile *>*files;
@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [[DemoDataManager shareManager].SMBSession requestContentsOfDirectoryAtFilePath:self.path success:^(NSArray <TOSMBSessionFile *>*files) {
        NSLog(@"获取成功");
        [files enumerateObjectsUsingBlock:^(TOSMBSessionFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.files addObject:obj];
        }];
        
        [self.tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.files[indexPath.row].filePath;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TOSMBSessionFile *f = self.files[indexPath.row];
    
    if (f.directory) {
        NSString *path = f.filePath;
        FileViewController *vc = [[FileViewController alloc] init];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:true];
    }
    else {
        PlayerViewController *vc = [[PlayerViewController alloc] init];
        vc.path = [self fullURLWithFile:f];
        [self.navigationController pushViewController:vc animated:true];
    }
}

#pragma mark - 私有方法

/**
 url编码生成完成的路径

 @param file 文件
 @return 完成的路径
 */
- (NSURL *)fullURLWithFile:(TOSMBSessionFile *)file {
    //smb://xiaoming:123456@192.168.1.100/xiaoming/Desktop/1.mp4
    TOSMBSession *session = [DemoDataManager shareManager].SMBSession;
    //两次URL编码
    NSMutableString *path = [[NSMutableString alloc] initWithString:@"smb://"];
    if (session.userName.length && session.password.length) {
        [path appendFormat:@"%@:%@@", [[session.userName stringByURLEncode] stringByURLEncode], [[session.password stringByURLEncode] stringByURLEncode]];
    }
    else if (session.userName.length && session.password.length == 0) {
        [path appendFormat:@"%@@", [[session.userName stringByURLEncode] stringByURLEncode]];
    }
    
    if (session.ipAddress.length) {
        [path appendString:session.ipAddress];
    }
    
    [path appendFormat:@"%@", [[file.filePath stringByURLEncode] stringByURLEncode]];
    
    return [NSURL URLWithString:path];
}

#pragma mark - 懒加载
- (NSMutableArray<TOSMBSessionFile *> *)files {
    if (_files == nil) {
        _files = [NSMutableArray array];
    }
    return _files;
}

@end
