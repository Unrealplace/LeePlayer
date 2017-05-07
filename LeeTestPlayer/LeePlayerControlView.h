//
//  LeePlayerControlView.h
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/23.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import <UIKit/UIKit.h>
// 图片路径
#define LeePlayerSrcName(file)               [@"LeePlayer.bundle" stringByAppendingPathComponent:file]

#define LeePlayerFrameworkSrcName(file)      [@"Frameworks/LeePlayer.framework/LeePlayer.bundle" stringByAppendingPathComponent:file]

#define LeePlayerImage(file)                 [UIImage imageNamed:LeePlayerSrcName(file)] ? :[UIImage imageNamed:LeePlayerFrameworkSrcName(file)]
#define RGBA(r,g,b,a)                       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define LeePlayerOrientationIsLandscape      UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)

#define LeePlayerOrientationIsPortrait       UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)
// 播放器的几种状态
typedef NS_ENUM(NSInteger, LeeBackState) {
    leeCloseStytle,
    leeBackSamllStytle
};
typedef NS_ENUM(NSInteger, LeeScreenState) {
    leePariteStytle,
    leeLandStytle
};

typedef void (^LeeControllBlock)(UIButton*,LeeBackState);
typedef void (^LeeScreenBlock)(LeeScreenState);
typedef void (^LeePlayBtnBlock)(UIButton*btn);
typedef void (^LeeSliderBlock)(UISlider*);
typedef void (^LeeSliderTapBlock)(CGFloat);
@interface LeePlayerControlView : UIView
@property (nonatomic,strong)UIButton * pauseBtn;
@property (nonatomic,copy)LeeControllBlock backBlock;
@property (nonatomic,copy)LeeScreenBlock fullScreenBlock;
@property (nonatomic,copy)LeePlayBtnBlock playBtnBlock;
@property (nonatomic,copy)LeeSliderBlock   sliderTouchBlock;
@property (nonatomic,copy)LeeSliderBlock   sliderMovBlock;
@property (nonatomic,copy)LeeSliderBlock   sliderEndBlock;
@property (nonatomic,copy)LeeSliderTapBlock sliderTapBlock;

-(void)playerDraggedEnd;
- (void)setPlayerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview;
- (void)setDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image;
- (void)setCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
-(void)setProgress:(CGFloat)progress;
-(void)showControlView;
-(void)ResetControlView;
-(void)setPlayBtnState:(BOOL)state;

@end
