//
//  LeeBaseNavigationController.m
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/24.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "LeeBaseNavigationController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface LeeBaseNavigationController ()

@end

@implementation LeeBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

   
    
}
-(BOOL)shouldAutorotate{
    
    return NO;
    
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
