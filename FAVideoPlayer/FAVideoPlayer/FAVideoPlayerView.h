//
//  FAVideoPlayerView.h
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 12/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@class AVPlayer;

@interface FAVideoPlayerView : UIView

@property AVPlayer *player;

@property (readonly) AVPlayerLayer *playerLayer;

@end
