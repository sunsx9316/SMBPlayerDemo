//
//  PlayerViewController.m
//  SMB_Link_Demo
//
//  Created by JimHuang on 2018/7/8.
//  Copyright © 2018年 jim. All rights reserved.
//

#import "PlayerViewController.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface PlayerViewController ()
@property (strong, nonatomic) VLCMediaPlayer *player;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.player = [[VLCMediaPlayer alloc] init];
    self.player.drawable = self.view;
    VLCMedia *media = [VLCMedia mediaWithURL:self.path];
    [self.player setMedia:media];
    
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
