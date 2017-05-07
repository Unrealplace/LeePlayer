//
//  LeeFirstVC.m
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/24.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "LeeFirstVC.h"
#import "LeePlayer.h"
#import "Masonry.h"
#import "LeeMovPlayerVC.h"

@interface LeeFirstVC ()

@end

@implementation LeeFirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton * nextBtn = [UIButton new];
    nextBtn.backgroundColor = [UIColor redColor];
    [nextBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.frame = CGRectMake(0, 0, 100, 100);
    nextBtn.center = self.view.center;
    [self.view addSubview:nextBtn];
    
    
    
}
-(void)nextClick:(UIButton*)sender{

    [self.navigationController pushViewController:[LeeMovPlayerVC new] animated:YES];
    
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
