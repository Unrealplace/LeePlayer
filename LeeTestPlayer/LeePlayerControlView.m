//
//  LeePlayerControlView.m
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/23.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "LeePlayerControlView.h"
#import "ASValueTrackingSlider.h"
#import "UIButton+largeArera.h"
#import "Masonry.h"


@interface LeePlayerControlView()<UIGestureRecognizerDelegate>
/** 标题 */
@property (nonatomic, strong) UILabel                 *lee_TitleLabel;
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *lee_StartBtn;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *lee_currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *lee_totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView          *lee_progressView;
/** 滑杆 */
@property (nonatomic, strong) ASValueTrackingSlider   *videoSlider;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *lee_fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong) UIButton                *lee_lockBtn;
/** 系统菊花 */
//@property (nonatomic, strong) MMMaterialDesignSpinner *activity;
/** 返回按钮*/
@property (nonatomic, strong) UIButton                *lee_backBtn;
/** 关闭按钮*/
@property (nonatomic, strong) UIButton                *lee_closeBtn;
/** 重播按钮 */
@property (nonatomic, strong) UIButton                *lee_repeatBtn;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *lee_bottomImageView;
/** topView */
@property (nonatomic, strong) UIImageView             *lee_topImageView;
/** 缓存按钮 */
@property (nonatomic, strong) UIButton                *lee_downLoadBtn;
/** 切换分辨率按钮 */
@property (nonatomic, strong) UIButton                *resolutionBtn;
/** 分辨率的View */
@property (nonatomic, strong) UIView                  *resolutionView;
/** 播放按钮 */
@property (nonatomic, strong) UIButton                *lee_playeBtn;
/** 加载失败按钮 */
@property (nonatomic, strong) UIButton                *lee_failBtn;
/** 快进快退View*/
@property (nonatomic, strong) UIView                  *lee_fastView;
/** 快进快退进度progress*/
@property (nonatomic, strong) UIProgressView          *lee_fastProgressView;
/** 快进快退时间*/
@property (nonatomic, strong) UILabel                 *lee_fastTimeLabel;
/** 快进快退ImageView*/
@property (nonatomic, strong) UIImageView             *lee_fastImageView;
/** 当前选中的分辨率btn按钮 */
@property (nonatomic, weak  ) UIButton                *resoultionCurrentBtn;
/** 占位图 */
@property (nonatomic, strong) UIImageView             *lee_placeholderImageView;
/** 控制层消失时候在底部显示的播放进度progress */
@property (nonatomic, strong) UIProgressView          *lee_bottomProgressView;

/** 显示控制层 */
@property (nonatomic, assign, getter=isShowing) BOOL  showing;
/** 是否拖拽slider控制播放进度 */
@property (nonatomic, assign, getter=isDragged) BOOL  dragged;
/** 是否播放结束 */
@property (nonatomic, assign, getter=isPlayEnd) BOOL  playeEnd;
/** 是否全屏播放 */
@property (nonatomic, assign,getter=isFullScreen)BOOL fullScreen;

@end
@implementation LeePlayerControlView

-(instancetype)init{

    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}
-(void)layoutSubviews{

    [super layoutSubviews];
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == UIDeviceOrientationPortrait) {
        [self setOrientationPortraitConstraint];
    } else {
        [self setOrientationLandscapeConstraint];
    }
}

-(void)setupUI{

    [self addSubview:self.lee_placeholderImageView];
    [self addSubview:self.lee_topImageView];
    [self addSubview:self.lee_bottomImageView];
    
    [self.lee_topImageView addSubview:self.lee_TitleLabel];
    [self.lee_topImageView addSubview:self.lee_backBtn];
    
    [self.lee_bottomImageView addSubview:self.lee_StartBtn];
    [self.lee_bottomImageView addSubview:self.lee_currentTimeLabel];
    [self.lee_bottomImageView addSubview:self.videoSlider];
    [self.lee_bottomImageView addSubview:self.lee_totalTimeLabel];
    [self.lee_bottomImageView addSubview:self.lee_fullScreenBtn];
    
    [self addSubview:self.lee_fastView];
    [self.lee_fastView addSubview:self.lee_fastTimeLabel];
    [self.lee_fastView addSubview:self.lee_fastImageView];
    
    [self addConstraints];
    
    
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self listeningRotating];
    [self onDeviceOrientationChange];
    

}
-(void)setProgress:(CGFloat)progress{

  [self.lee_progressView setProgress:progress animated:NO];
    
}

- (void)setCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value
{
    // 当前时长进度progress
    NSInteger proMin = currentTime / 60;//当前秒
    NSInteger proSec = currentTime % 60;//当前分钟
    // duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    if (!self.isDragged) {
        // 更新slider
        self.videoSlider.value           = value;
        self.lee_bottomProgressView.progress = value;
        // 更新当前播放时间
        self.lee_currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    
    self.videoSlider.value           = value;

    // 更新当前播放时间
    self.lee_currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    // 更新总时间
    self.lee_totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}
-(void)showControlView{

    
}
-(void)ResetControlView{

    //[self.activity stopAnimating];
    self.videoSlider.value           = 0;
    self.lee_bottomProgressView.progress = 0;
    self.lee_progressView.progress       = 0;
    self.lee_currentTimeLabel.text       = @"00:00";
    self.lee_totalTimeLabel.text         = @"00:00";
    self.lee_fastView.hidden             = YES;
    self.lee_repeatBtn.hidden            = YES;
    self.lee_StartBtn.hidden             = YES;
    self.resolutionView.hidden       = YES;
    self.lee_failBtn.hidden              = YES;
    self.backgroundColor             = [UIColor clearColor];
//    self.downLoadBtn.enabled         = YES;
//    self.shrink                      = NO;
    self.showing                     = NO;
    self.playeEnd                    = NO;
    self.lee_lockBtn.hidden              = !self.isFullScreen;
    self.lee_failBtn.hidden              = YES;
    self.lee_placeholderImageView.alpha  = 1;
}
-(void)setDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image{

    // 拖拽的时长
    NSInteger proMin = draggedTime / 60;//当前秒
    NSInteger proSec = draggedTime % 60;//当前分钟
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    [self.videoSlider setImage:image];
    [self.videoSlider setText:currentTimeStr];
    self.lee_fastView.hidden = YES;
}
-(void)setPlayerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview{

    // 快进快退时候停止菊花
   // [self.activity stopAnimating];
    // 拖拽的时长
    NSInteger proMin = draggedTime / 60;//当前秒
    NSInteger proSec = draggedTime % 60;//当前分钟
    
    //duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    NSString *totalTimeStr   = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    CGFloat  draggedValue    = (CGFloat)draggedTime/(CGFloat)totalTime;
    NSString *timeStr        = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totalTimeStr];
    
    // 显示、隐藏预览窗
    self.videoSlider.popUpView.hidden = !preview;
    // 更新slider的值
    self.videoSlider.value            = draggedValue;
    // 更新bottomProgressView的值
    self.lee_bottomProgressView.progress  = draggedValue;
    // 更新当前时间
    self.lee_currentTimeLabel.text        = currentTimeStr;
    // 正在拖动控制播放进度
    self.dragged = YES;
    
    if (forawrd) {
        self.lee_fastImageView.image = LeePlayerImage(@"ZFPlayer_fast_forward");
    } else {
        self.lee_fastImageView.image = LeePlayerImage(@"ZFPlayer_fast_backward");
    }
    self.lee_fastView.hidden           = preview;
    self.lee_fastTimeLabel.text        = timeStr;
    self.lee_fastProgressView.progress = draggedValue;
}
-(void)setPlayBtnState:(BOOL)state{

    self.lee_StartBtn.selected = state;
}

-(void)appDidEnterBackground{

    
}
-(void)appDidEnterPlayground{

    
}
/**
 *  监听设备旋转通知
 */
- (void)listeningRotating
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange
{
//    if (ZFPlayerShared.isLockScreen) { return; }
//    self.lockBtn.hidden         = !self.isFullScreen;
//    self.fullScreenBtn.selected = self.isFullScreen;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationPortraitUpsideDown) { return; }
    if (LeePlayerOrientationIsLandscape) {
        [self setOrientationLandscapeConstraint];
    } else {
        [self setOrientationPortraitConstraint];
    }
    [self layoutIfNeeded];
    [self setNeedsLayout];

}

- (void)setOrientationLandscapeConstraint
{

    self.fullScreen             = YES;
    self.lee_lockBtn.hidden         = !self.isFullScreen;
    self.lee_fullScreenBtn.selected = self.isFullScreen;
    [self.lee_backBtn setImage:LeePlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
    [self.lee_backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(27);
    }];
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortraitConstraint
{
    self.fullScreen             = NO;
    self.lee_lockBtn.hidden         = !self.isFullScreen;
    self.lee_fullScreenBtn.selected = self.isFullScreen;
    [self.lee_backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(7);
    }];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


-(void)addConstraints{

    [self.lee_placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
        
    }];
    [self.lee_topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    [self.lee_bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self.lee_TitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lee_backBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.lee_backBtn.mas_centerY);
        make.trailing.equalTo(self.mas_trailing).offset(-10);
    }];
    [self.lee_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lee_topImageView.mas_leading).offset(10);
        make.top.equalTo(self.lee_topImageView.mas_top).offset(7);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.lee_StartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.leading.equalTo(self.lee_bottomImageView.mas_leading).offset(5);
        make.bottom.equalTo(self.lee_bottomImageView.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
    }];
    [self.lee_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lee_StartBtn.mas_trailing).offset(-3);
        make.centerY.equalTo(self.lee_StartBtn.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    [self.lee_fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.lee_bottomImageView.mas_trailing).offset(-5);
        make.centerY.equalTo(self.lee_StartBtn.mas_centerY);
    }];
    
    [self.lee_totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.lee_fullScreenBtn.mas_leading).offset(3);
        make.centerY.equalTo(self.lee_StartBtn.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lee_currentTimeLabel.mas_trailing).offset(4);
        make.trailing.equalTo(self.lee_totalTimeLabel.mas_leading).offset(-4);
        make.centerY.equalTo(self.lee_currentTimeLabel.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    [self.lee_fastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(70);
        make.center.equalTo(self);
    }];
    
    [self.lee_fastImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_offset(32);
        make.height.mas_offset(32);
        make.top.mas_equalTo(5);
        make.centerX.mas_equalTo(self.lee_fastView.mas_centerX);
    }];
    
    [self.lee_fastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.with.trailing.mas_equalTo(0);
        make.top.mas_equalTo(self.lee_fastImageView.mas_bottom).offset(2);
    }];
    
    
}

#pragma allGetter 方法
-(UIImageView*)lee_placeholderImageView{

    if (!_lee_placeholderImageView) {
        _lee_placeholderImageView = [UIImageView new];
        _lee_placeholderImageView.userInteractionEnabled = YES;
    }
    return _lee_placeholderImageView;
    
}
-(UIImageView*)lee_topImageView{

    if (!_lee_topImageView) {
        _lee_topImageView = [UIImageView new];
        _lee_topImageView.userInteractionEnabled = YES;
        _lee_topImageView.image = LeePlayerImage(@"ZFPlayer_top_shadow");
    }
    return _lee_topImageView;
}
-(UIImageView*)lee_bottomImageView{

    if (!_lee_bottomImageView) {
        _lee_bottomImageView = [UIImageView new];
        _lee_bottomImageView.userInteractionEnabled = YES;
        _lee_bottomImageView.image = LeePlayerImage(@"ZFPlayer_bottom_shadow");
        
    }
    return _lee_bottomImageView;
    
}
-(UILabel*)lee_TitleLabel{

    if (!_lee_TitleLabel) {
        _lee_TitleLabel = [UILabel new];
        _lee_TitleLabel.text = @"oliver lee title";
        _lee_TitleLabel.textColor     = [UIColor whiteColor];
        _lee_TitleLabel.font          = [UIFont systemFontOfSize:15.0f];
    }
    return _lee_TitleLabel;
}
-(UIButton*)lee_backBtn{

    if (!_lee_backBtn) {
        _lee_backBtn = [UIButton new];
        [_lee_backBtn setImage:LeePlayerImage(@"ZFPlayer_back_full@2x") forState:UIControlStateNormal];
        [_lee_backBtn setShowsTouchWhenHighlighted:YES];
        
        [_lee_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lee_backBtn setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];

    }
    return _lee_backBtn;
}

-(UIButton*)lee_StartBtn{

    if (!_lee_StartBtn) {
        _lee_StartBtn = [UIButton new];
        [_lee_StartBtn setImage:LeePlayerImage(@"ZFPlayer_play") forState:UIControlStateNormal];
        [_lee_StartBtn setImage:LeePlayerImage(@"ZFPlayer_pause") forState:UIControlStateSelected];
        [_lee_StartBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
         [_lee_StartBtn setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        _lee_StartBtn.selected = YES;
    }
    return _lee_StartBtn;
    
}

-(UILabel*)lee_currentTimeLabel{

    if (!_lee_currentTimeLabel) {
        _lee_currentTimeLabel = [UILabel new];
        _lee_currentTimeLabel.textColor     = [UIColor whiteColor];
        _lee_currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
    }
    return _lee_currentTimeLabel;
}

-(UILabel*)lee_totalTimeLabel{

    if (!_lee_totalTimeLabel) {
        _lee_totalTimeLabel = [UILabel new];
        _lee_totalTimeLabel.textColor     = [UIColor whiteColor];
        _lee_totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
    }
    return _lee_totalTimeLabel;
    
}
-(UIView*)lee_fastView{

    if (!_lee_fastView) {
        _lee_fastView                     = [[UIView alloc] init];
        _lee_fastView.backgroundColor     = RGBA(0, 0, 0, 0.8);
        _lee_fastView.layer.cornerRadius  = 4;
        _lee_fastView.layer.masksToBounds = YES;
    }
    return _lee_fastView;
}
-(UIImageView*)lee_fastImageView{

    if (!_lee_fastImageView) {
        _lee_fastImageView = [UIImageView new];
        
    }
    return _lee_fastImageView;
}
-(UILabel*)lee_fastTimeLabel{

    if (!_lee_fastTimeLabel) {

        _lee_fastTimeLabel               = [[UILabel alloc] init];
        _lee_fastTimeLabel.textColor     = [UIColor whiteColor];
        _lee_fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _lee_fastTimeLabel.font          = [UIFont systemFontOfSize:14.0];
    
    }
    return _lee_fastTimeLabel;
    
}

- (ASValueTrackingSlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider                       = [[ASValueTrackingSlider alloc] init];
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        
        [_videoSlider setThumbImage:LeePlayerImage(@"ZFPlayer_slider") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        // slider开始滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [_videoSlider addGestureRecognizer:sliderTap];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
       // [_videoSlider addGestureRecognizer:panRecognizer];
    }
    return _videoSlider;
}
-(UIButton *)lee_fullScreenBtn{

    if (!_lee_fullScreenBtn) {
        _lee_fullScreenBtn = [UIButton new];
        [_lee_fullScreenBtn setImage:LeePlayerImage(@"ZFPlayer_fullscreen") forState:UIControlStateNormal];
        [_lee_fullScreenBtn setImage:LeePlayerImage(@"ZFPlayer_shrinkscreen") forState:UIControlStateSelected];
        [_lee_fullScreenBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lee_fullScreenBtn setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        
    }
    return _lee_fullScreenBtn;
}


#pragma 控制层的各种事件
-(void)backBtnClick:(UIButton*)sender{

    // 状态条的方向旋转的方向,来判断当前屏幕的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (orientation == UIInterfaceOrientationPortrait) {
        
        if (self.backBlock) {
            self.backBlock(sender,leeCloseStytle);
        }
    } else {
        if (self.backBlock) {
            self.backBlock(sender,leeBackSamllStytle);
        }
        
    }
    
}


/**
 *  显示控制层
 */
- (void)zf_playerShowControlView
{
//    if (self.isShowing) {
//        [self zf_playerHideControlView];
//        return;
//    }
//    [self zf_playerCancelAutoFadeOutControlView];
//    [UIView animateWithDuration:ZFPlayerControlBarAutoFadeOutTimeInterval animations:^{
//        [self showControlView];
//    } completion:^(BOOL finished) {
//        self.showing = YES;
//        [self autoFadeOutControlView];
//    }];
    
}
-(void)playerDraggedEnd{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.lee_fastView.hidden = YES;
    });
    self.dragged = NO;
    // 结束滑动时候把开始播放按钮改为播放状态
    self.lee_StartBtn.selected = YES;
    // 滑动结束延时隐藏controlView
   // [self autoFadeOutControlView];
}



-(void)startBtnClick:(UIButton*)sender{

    if (self.playBtnBlock) {
        self.playBtnBlock(sender);
    }
}
-(void)fullBtnClick:(UIButton*)sender{

    if (self.fullScreenBlock) {
        self.fullScreenBlock(leeLandStytle);
    }
   
}

-(void)progressSliderTouchBegan:(ASValueTrackingSlider*)slider{

    if (self.sliderTouchBlock) {
        self.sliderTouchBlock(slider);
    }
    
}
-(void)progressSliderValueChanged:(ASValueTrackingSlider*)slider{

    if (self.sliderMovBlock) {
        self.sliderMovBlock(slider);
    }
    
}
-(void)progressSliderTouchEnded:(ASValueTrackingSlider*)slider{

    if (self.sliderEndBlock) {
        self.sliderEndBlock(slider);
    }
    
}
-(void)tapSliderAction:(UIGestureRecognizer*)gester{
    if ([gester.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)gester.view;
        CGPoint point = [gester locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        if (self.sliderTapBlock) {
            self.sliderTapBlock(tapValue);
        }
    }
    
}
-(void)panRecognizer:(UIGestureRecognizer*)gester{};

@end
