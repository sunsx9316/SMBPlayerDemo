//
//  DemoDataManager.m
//  SMB_Link_Demo
//
//  Created by JimHuang on 2018/7/8.
//  Copyright © 2018年 jim. All rights reserved.
//

#import "DemoDataManager.h"
#import <TOSMBSession.h>

@implementation DemoDataManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static DemoDataManager *_m = nil;
    dispatch_once(&onceToken, ^{
        _m = [[DemoDataManager alloc] init];
    });
    return _m;
}

- (void)setInfo:(DDPSMBInfo *)info {
    _info = info;
    
    TOSMBSession *session = [[TOSMBSession alloc] init];
    session.password = _info.password;
    session.userName = _info.userName;
    session.hostName = _info.hostName;
    session.ipAddress = _info.ipAddress;
    self.SMBSession = session;
}

@end
