//
//  LeeThirdVC.m
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/24.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "LeeThirdVC.h"

@interface LeeThirdVC ()

@end

@implementation LeeThirdVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
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
