//
//  ViewController.m
//  SMB_Link_Demo
//
//  Created by JimHuang on 2018/7/3.
//  Copyright © 2018年 jim. All rights reserved.
//

#import "ViewController.h"
#import <TOSMBClient.h>
#import <YYCategories.h>
#import "DemoTableViewCell.h"
#import "FileViewController.h"
#import "DDPSMBInfo.h"
#import "DemoDataManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray <TONetBIOSNameServiceEntry *>*nameServiceEntries;
@property (strong, nonatomic) TONetBIOSNameService *netbiosService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        //为了弹出网络权限的提示框 没实际意义
        TOSMBSession *SMBSession = [[TOSMBSession alloc] init];
        [SMBSession requestContentsOfDirectoryAtFilePath:@"/" success:^(NSArray <TOSMBSessionFile *>*files) {
            
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(touchRightBarButtonItem)];
    
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = control;
    
    [self beginRefresh:control];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    TONetBIOSNameServiceEntry *entry = self.nameServiceEntries[indexPath.row];
    [self showLoginViewWithEntry:entry];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nameServiceEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TONetBIOSNameServiceEntry *model = self.nameServiceEntries[indexPath.row];
    
    DemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoTableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.ipAddressString;
    return cell;
}

#pragma mark - 私有方法
- (void)showLoginViewWithEntry:(TONetBIOSNameServiceEntry *)entry {
    
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"登录SMB服务器" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    DDPSMBInfo *model = [[DDPSMBInfo alloc] init];
    
    @weakify(vc)
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *firstText = weak_vc.textFields.firstObject.text;
        if ([self isIpAdressWithString:firstText]) {
            model.ipAddress = firstText;
        }
        else {
            model.hostName = firstText;
        }
        model.userName = weak_vc.textFields[1].text;
        model.password = weak_vc.textFields[2].text;
        [self loginWithModel:model];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"服务器或ip 不区分大小写";
        textField.text = entry.name;
        textField.font = [UIFont systemFontOfSize:15];
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"用户名";
        textField.font = [UIFont systemFontOfSize:15];
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
        textField.font = [UIFont systemFontOfSize:15];
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)beginRefresh:(UIRefreshControl *)control {
    [self.netbiosService stopDiscovery];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [control endRefreshing];
    });
    
    self.netbiosService = [[TONetBIOSNameService alloc] init];
    
    BOOL flag = [self.netbiosService startDiscoveryWithTimeOut:4.0f added:^(TONetBIOSNameServiceEntry *entry) {
        [self.nameServiceEntries addObject:entry];
        [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSLog(@"连接成功 %@", entry.name);
        
    } removed:^(TONetBIOSNameServiceEntry *entry) {
        [self.nameServiceEntries removeObject:entry];
        [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"连接失败 %@", entry.name);
    }];
    
    NSLog(@"启动 %d", flag);
}

- (BOOL)isIpAdressWithString:(NSString *)str {
    return [str matchesRegex:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionCaseInsensitive];
}

- (void)loginWithModel:(DDPSMBInfo *)model {
    
    NSLog(@"连接中...");
    
    void(^loginAction)(DDPSMBInfo *) = ^(DDPSMBInfo *aModel) {
        [DemoDataManager shareManager].info = aModel;
        
        FileViewController *vc = [[FileViewController alloc] init];
        vc.path = @"/";
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    if (model.ipAddress.length && model.hostName.length == 0) {
        [self.netbiosService lookupNetworkNameForIPAddress:model.ipAddress success:^(NSString *name) {
            model.hostName = name;
            loginAction(model);
        } failure:^{
            NSLog(@"登录失败");
        }];
    }
    else {
        loginAction(model);
    }
}

- (void)touchRightBarButtonItem {
    [self showLoginViewWithEntry:nil];
}

#pragma mark - 懒加载
- (NSMutableArray<TONetBIOSNameServiceEntry *> *)nameServiceEntries {
    if (_nameServiceEntries == nil) {
        _nameServiceEntries = [NSMutableArray array];
    }
    return _nameServiceEntries;
}

@end
