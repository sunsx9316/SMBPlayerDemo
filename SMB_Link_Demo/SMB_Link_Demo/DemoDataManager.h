//
//  DemoDataManager.h
//  SMB_Link_Demo
//
//  Created by JimHuang on 2018/7/8.
//  Copyright © 2018年 jim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPSMBInfo.h"

@class TOSMBSession;
@interface DemoDataManager : NSObject

+ (instancetype)shareManager;

@property (strong, nonatomic) DDPSMBInfo *info;

@property (strong, nonatomic) TOSMBSession *SMBSession;

@end
