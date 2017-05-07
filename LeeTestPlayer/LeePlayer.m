//
//  LeePlayer.m
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/23.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "LeePlayer.h"
#import "LeePlayerControlView.h"
#import "Masonry.h"
#import "LeeCommonHeader.h"
// 屏幕的宽
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface LeePlayer()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)LeePlayerControlView * controlView;

/** 是否为全屏 */
@property (nonatomic, assign) BOOL                   isFullScreen;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                   isLocked;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL                   isPauseByUser;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL                   isLocalVideo;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat                sliderLastValue;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL                   repeatToPlay;
/** 播放完了*/
@property (nonatomic, assign) BOOL                   playDidEnd;
/** 进入后台*/
@property (nonatomic, assign) BOOL                   didEnterBackground;
/** 是否自动播放 */
@property (nonatomic, assign) BOOL                   isAutoPlay;
/** 单击 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
/** 双击 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
/** 视频URL的数组 */
@property (nonatomic, strong) NSArray                *videoURLArray;
/** slider预览图 */
@property (nonatomic, strong) UIImage                *thumbImg;
/** 亮度view */
//@property (nonatomic, strong) ZFBrightnessView       *brightnessView;
/** 是否正在拖拽 */
@property (nonatomic, assign) BOOL                   isDragged;

@property (nonatomic, assign) LeePlayerState         state;

@property (nonatomic, assign) NSInteger              seekTime;

@property (nonatomic, strong) id                     timeObserve;

@end
@implementation LeePlayer
-(instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        [self setupUI];
    }
    return self;
    
}
-(void)layoutSubviews{
    
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;

}
-(void)dealloc{
    
    LeeLog(@"dealloc");
    [self.player pause];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    // 把player置为nil
    self.playerItem      = nil;
    self.imageGenerator  = nil;
    self.player          = nil;
    self.controlView     = nil;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
}

#pragma mark 关闭播放器
-(void)closePlayer{
    
    [self resetPlayer];
    UINavigationController* nav =  [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers[0];
    [nav popViewControllerAnimated:YES];
    [self removeFromSuperview];
    
}

#pragma mark
-(void)setupUI{
    self.controlView = [LeePlayerControlView new];
    [self blockCallBack];
}

#pragma mark - Getter

- (AVAssetImageGenerator *)imageGenerator
{
    if (!_imageGenerator) {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.avUrlAsset];
    }
    return _imageGenerator;
}

#pragma mark 所有的 setter 方法
-(void)setControlView:(LeePlayerControlView *)controlView{
    
    _controlView = controlView;
    _controlView.backgroundColor = [UIColor clearColor];
    [self addSubview:_controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.mas_equalTo(self);
    }];
    
}
-(void)setPlayUrl:(NSString *)playUrl{
    
    _playUrl = playUrl;
    // 每次加载视频URL都设置重播为NO
    self.repeatToPlay = NO;
    self.playDidEnd   = NO;
    self.isPauseByUser = NO;
    // 添加通知
    [self addNotifications];
    self.isPauseByUser = YES;
    // 添加手势
    [self createGesture];
        
}
-(void)setIsPauseByUser:(BOOL)isPauseByUser{

    _isPauseByUser = isPauseByUser;

}
-(void)setState:(LeePlayerState)state{

    
    
}


- (void)createTimer
{
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf.controlView setCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

/**
 *  创建手势
 */
- (void)createGesture
{
    // 单击
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:self.singleTap];
    
    // 双击(播放/暂停)
    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    self.doubleTap.delegate                = self;
    self.doubleTap.numberOfTouchesRequired = 1; //手指数
    self.doubleTap.numberOfTapsRequired    = 2;
    
    [self addGestureRecognizer:self.doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

#pragma mark - 点击手势
- (void)singleTapAction:(UIGestureRecognizer *)gesture{
   
    if (gesture.state == UIGestureRecognizerStateRecognized) {
            if (self.playDidEnd) { return; }
            else { [self.controlView showControlView];
            }
    }
    
}

- (void)doubleTapAction:(UIGestureRecognizer *)gesture{
    
    if (self.playDidEnd) { return;  }
    // 显示控制层
//    [self.controlView zf_playerCancelAutoFadeOutControlView];
//    [self.controlView zf_playerShowControlView];
    if (self.isPauseByUser) { [self play]; }
    else { [self pause]; }
//    if (!self.isAutoPlay) {
//        self.isAutoPlay = YES;
//        [self configZFPlayer];
//    }
}

/** 全屏 */
- (void)fullScreenAction{
    
    // 如果是全屏的话
    if (self.isFullScreen) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        self.isFullScreen = NO;
        return;
    } else {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        self.isFullScreen = YES;
    }

}


/**
 *  重置player
 */
- (void)resetPlayer
{
    // 改为为播放完
    self.playDidEnd         = NO;
    self.playerItem         = nil;
    self.didEnterBackground = NO;
    // 视频跳转秒数置0
    //self.seekTime           = 0;
    self.isAutoPlay         = NO;
//    if (self.timeObserve) {
//        [self.player removeTimeObserver:self.timeObserve];
//        self.timeObserve = nil;
//    }
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 暂停
    [self pause];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    // 把player置为nil
    self.imageGenerator = nil;
    self.player         = nil;
//    if (self.isChangeResolution) { // 切换分辨率
//        [self.controlView zf_playerResetControlViewForResolution];
//        self.isChangeResolution = NO;
//    }else { // 重置控制层View
//        [self.controlView zf_playerResetControlView];
//    }
    self.controlView   = nil;
    // 非重播时，移除当前playerView
    if (!self.repeatToPlay) { [self removeFromSuperview]; }
}


-(void)setLeePlayer{

    self.isFullScreen = NO;
    self.avUrlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.playUrl]];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.avUrlAsset];
    self.player     = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer= [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加播放进度计时器
    [self createTimer];

    
    
}


/**
 *  根据playerItem，来添加移除观察者
 *
 *  @param playerItem playerItem
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    // 先移除观察者
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    //在添加观测着
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}


-(void)moviePlayDidEnd:(NSNotification*)sender{

    
}
#pragma mark - 观察者、通知

/**
 *  添加观察者、通知
 */
- (void)addNotifications
{

    
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    // 监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}


-(void)appDidEnterBackground{

    self.didEnterBackground     = YES;
    // 退到后台锁定屏幕方向
   // ZFPlayerShared.isLockScreen = YES;
    [_player pause];
    self.state                  = LeePlayerStatePause;
}
-(void)appDidEnterPlayground{

    self.didEnterBackground     = NO;
    // 根据是否锁定屏幕方向 来恢复单例里锁定屏幕的方向
    //ZFPlayerShared.isLockScreen = self.isLocked;
    if (!self.isPauseByUser) {
        self.state         = LeePlayerStatePlaying;
        self.isPauseByUser = NO;
        [self play];
    }
}
#pragma mark 屏幕转屏相关

/**
 *  屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        self.isFullScreen = YES;
        // 设置横屏
        [self setOrientationLandscapeConstraint:orientation];
    } else if (orientation == UIInterfaceOrientationPortrait) {
        self.isFullScreen = NO;
        // 设置竖屏
        [self setOrientationPortraitConstraint];
    }
}
/**
*  设置横屏的约束
*/
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation
{
    [self toOrientation:orientation];
 }
/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortraitConstraint
{

    [self addPlayerToFatherView:self.fatherView];
    [self toOrientation:UIInterfaceOrientationPortrait];
}
- (void)addPlayerToFatherView:(UIView *)view{

    [self removeFromSuperview];
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
}
/**
 *  屏幕方向发生变化会调用这里 这是一个变化方法
 */
- (void)onDeviceOrientationChange
{
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown ) { return; }
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
        }
            break;
        case UIInterfaceOrientationPortrait:{
           
            [self toOrientation:UIInterfaceOrientationPortrait];

        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];

            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            [self toOrientation:UIInterfaceOrientationLandscapeRight];

        }
            break;
        default:
            break;
    }
}

// 状态条变化通知（在前台播放才去处理）这是另一个变化的方法
- (void)onStatusBarOrientationChange
{
        // 获取到当前状态条的方向
        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [self setOrientationPortraitConstraint];
        } else {
            if (currentOrientation == UIInterfaceOrientationLandscapeRight) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            } else if (currentOrientation == UIDeviceOrientationLandscapeLeft){
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
           
        }
   
}
- (void)toOrientation:(UIInterfaceOrientation)orientation
{
    
    // 获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;

    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) { return; }
    
    // 根据要旋转的方向,使用Masonry重新修改限制
    if (orientation != UIInterfaceOrientationPortrait) {//
        self.isFullScreen = YES;
        // 这个地方加判断是为了从全屏的一侧,直接到全屏的另一侧不用修改限制,否则会出错;
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [self removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow insertSubview:self atIndex:1];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(ScreenHeight));
                make.height.equalTo(@(ScreenWidth));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
    }else{
    
        self.isFullScreen = NO;
      
        NSLog(@"切换到竖屏了。。。。。。");
        
    }
    // iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    // 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    self.transform = CGAffineTransformIdentity;
    self.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
    [self.controlView layoutIfNeeded];
    [self.controlView setNeedsLayout];
}

/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle
{
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
                // 添加playerLayer到self.layer
                [self.layer insertSublayer:self.playerLayer atIndex:0];
                self.state = LeePlayerStatePlaying;
                // 加载完成后，再添加平移手势
                // 添加平移手势，用来控制音量、亮度、快进快退
                               
                // 跳到xx秒播放视频
//                if (self.seekTime) {
//                    [self seekToTime:self.seekTime completionHandler:nil];
//                }
//                self.player.muted = self.mute;
                [self play];
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.state = LeePlayerStateFailed;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.controlView setProgress:timeInterval / totalDuration];
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.state = LeePlayerStateBuffering;
                [self bufferingSomeSecond];
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.state == LeePlayerStateBuffering){
                self.state = LeePlayerStatePlaying;
            }
            
        }
    }
    
}

#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond
{
    self.state = LeePlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
        
    });
}
-(void)play{


    [self.controlView setPlayBtnState:YES];
    if (self.state == LeePlayerStatePause) { self.state = LeePlayerStatePlaying; }
    self.isPauseByUser = NO;
    [_player play];
//    if (!self.isBottomVideo) {
//        // 显示控制层
////        [self.controlView zf_playerCancelAutoFadeOutControlView];
////        [self.controlView zf_playerShowControlView];
//    }

}
-(void)pause{

    [self.controlView setPlayBtnState:NO];
    if (self.state == LeePlayerStatePlaying) { self.state = LeePlayerStatePause;}
    self.isPauseByUser = YES;
    [_player pause];
    
}

#pragma mark 所有的控制层block 回调的方法
-(void)blockCallBack{
    LeeWeakSelf(self);
    
    self.controlView.backBlock = ^(UIButton * backBtn,LeeBackState style){
        style == leeBackSamllStytle? [weakself interfaceOrientation:UIInterfaceOrientationPortrait]:[weakself closePlayer];
    };
    self.controlView.fullScreenBlock = ^(LeeScreenState stytle){
        
        [weakself fullScreenAction];
    };
    self.controlView.playBtnBlock  = ^(UIButton * btn){
        
        // 这里要判断状态
        if (btn.selected) {
            btn.selected = !btn.selected;
            [weakself.player pause];
        }else{
            
            btn.selected = !btn.selected;
            [weakself.player play];
        }
        
    };
    self.controlView.sliderTapBlock  = ^(CGFloat value){
    
        // 视频总时间长度
        CGFloat total = (CGFloat)weakself.playerItem.duration.value / weakself.playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * value);
        
        [weakself.controlView setPlayBtnState:YES];
        [weakself seekToTime:dragedSeconds completionHandler:^(BOOL finished) {}];
    };
    self.controlView.sliderTouchBlock = ^(UISlider* slider){
    
        
    };
    self.controlView.sliderMovBlock   = ^(UISlider* slider){
    

        // 拖动改变视频播放进度
        if (weakself.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            weakself.isDragged = YES;
            BOOL style = false;
            CGFloat value   = slider.value - weakself.sliderLastValue;
            if (value > 0) { style = YES; }
            if (value < 0) { style = NO; }
            if (value == 0) { return; }
            
            weakself.sliderLastValue  = slider.value;
            
            CGFloat totalTime     = (CGFloat)weakself.playerItem.duration.value / weakself.playerItem.duration.timescale;
            
            //计算出拖动的当前秒数
            CGFloat dragedSeconds = floorf(totalTime * slider.value);
            
            //转换成CMTime才能给player来控制播放进度
            CMTime dragedCMTime   = CMTimeMake(dragedSeconds, 1);
            
            [weakself.controlView setPlayerDraggedTime:dragedSeconds totalTime:totalTime isForward:style hasPreview:weakself.isFullScreen ? weakself.hasPreviewView : NO];
            

            if (totalTime > 0) { // 当总时长 > 0时候才能拖动slider
                if (weakself.isFullScreen && weakself.hasPreviewView) {
                    
                    [weakself.imageGenerator cancelAllCGImageGeneration];
                    weakself.imageGenerator.appliesPreferredTrackTransform = YES;
                    weakself.imageGenerator.maximumSize = CGSizeMake(100, 56);
                    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){

                        if (result != AVAssetImageGeneratorSucceeded) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakself.controlView setDraggedTime:dragedSeconds sliderImage:weakself.thumbImg ? : LeePlayerImage(@"ZFPlayer_loading_bgView")];
                            });
                        } else {
                            weakself.thumbImg = [UIImage imageWithCGImage:im];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakself.controlView setDraggedTime:dragedSeconds sliderImage:weakself.thumbImg ? : LeePlayerImage(@"ZFPlayer_loading_bgView")];
                            });
                        }
                    };
                    [weakself.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:handler];
                }
            } else {
                // 此时设置slider值为0
                slider.value = 0;
            }
            
        }else { // player状态加载失败
            // 此时设置slider值为0
            slider.value = 0;
        }

    };

    self.controlView.sliderEndBlock   = ^(UISlider * slider){
    
        if (weakself.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            weakself.isPauseByUser = NO;
            weakself.isDragged = NO;
            // 视频总时间长度
            CGFloat total           = (CGFloat)weakself.playerItem.duration.value / weakself.playerItem.duration.timescale;
            //计算出拖动的当前秒数
            NSInteger dragedSeconds = floorf(total * slider.value);
            [weakself seekToTime:dragedSeconds completionHandler:nil];
        }
    };
}

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        //[self.controlView zf_playerActivity:YES];
        [self.player pause];
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
           // [weakSelf.controlView zf_playerActivity:NO];
            // 视频跳转回调
            if (completionHandler) { completionHandler(finished); }
            [weakSelf.player play];
            weakSelf.seekTime = 0;
            weakSelf.isDragged = NO;
            // 结束滑动
            [weakSelf.controlView  playerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) { weakSelf.state = LeePlayerStateBuffering; }
            
        }];
    }
}


@end
