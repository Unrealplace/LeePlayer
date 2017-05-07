//
//  LeePlayer.h
//  LeeTestPlayer
//
//  Created by LiYang on 17/2/23.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
// 播放器的几种状态
typedef NS_ENUM(NSInteger, LeePlayerState) {
    LeePlayerStateFailed,     // 播放失败
    LeePlayerStateBuffering,  // 缓冲中
    LeePlayerStatePlaying,    // 播放中
    LeePlayerStateStopped,    // 停止播放
    LeePlayerStatePause       // 暂停播放
};
@interface LeePlayer : UIView

@property (nonatomic,copy)NSString * playUrl;

@property (nonatomic,strong)AVURLAsset * avUrlAsset;

@property (nonatomic,strong)AVPlayerItem * playerItem;

@property (nonatomic,strong)AVAssetImageGenerator * imageGenerator;

@property (nonatomic,strong)AVPlayer     * player;

@property (nonatomic,strong)AVPlayerLayer * playerLayer;

@property (nonatomic,weak)UIView       * fatherView;


/** 是否有下载功能(默认是关闭) */
@property (nonatomic, assign) BOOL                    hasDownload;
/** 是否开启预览图 */
@property (nonatomic, assign) BOOL                    hasPreviewView;
/** 设置代理 */
//@property (nonatomic, weak) id<ZFPlayerDelegate>      delegate;
/** 是否被用户暂停 */
@property (nonatomic, assign, readonly) BOOL          isPauseByUser;
/** 播发器的几种状态 */
@property (nonatomic, assign, readonly) LeePlayerState state;
/** 静音（默认为NO）*/
@property (nonatomic, assign) BOOL                    mute;


- (void)setLeePlayer;
- (void)addPlayerToFatherView:(UIView *)view;

@end
