//
//  LeeMovPlayerVC.m
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/24.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "LeeMovPlayerVC.h"
#import "LeePlayer.h"
#import "Masonry.h"
#import "LeeThirdVC.h"
#import "LeeCommonHeader.h"

@interface LeeMovPlayerVC ()

@property (nonatomic,strong)LeePlayer * leePlayer;
@property (nonatomic,strong)UIView * fatherView;

@end

@implementation LeeMovPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView * blackView = [UIView new];
    [self.view addSubview:blackView];
    blackView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    blackView.backgroundColor = [UIColor blackColor];

    
    [self setPlayer];
    
    UIButton * nextBtn = [UIButton new];
    nextBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.frame = CGRectMake(0, 0, 100, 40);
    [nextBtn setTitle:@"下一页" forState:UIControlStateNormal];
    nextBtn.center = CGPointMake(self.view.center.x, 500);
    
}
-(void)nextBtnClick:(UIButton*)btn{

    [self.navigationController pushViewController:[LeeThirdVC new] animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
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
-(void)dealloc{

    LeeLog(@"%@dealloc",self.class);

    self.leePlayer = nil;
    
    
}

-(void)setPlayer{
    
    self.fatherView = [UIView new];
    _fatherView.frame    = CGRectMake(0, 20,self.view.bounds.size.width, self.view.bounds.size.width*9/16.0);
    [self.view addSubview:_fatherView];
    _fatherView.backgroundColor = [UIColor whiteColor];

    LeePlayer * player = [[LeePlayer alloc] init];
    
    self.leePlayer = player;
    
    player.fatherView     =  _fatherView;
    
    [_fatherView addSubview:player];
    [player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
    
    
    player.playUrl = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    
    [player setLeePlayer];
    
    
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
