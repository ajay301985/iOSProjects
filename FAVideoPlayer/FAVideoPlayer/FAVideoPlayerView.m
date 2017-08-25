//
//  FAVideoPlayerView.m
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 12/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import "FAVideoPlayerView.h"

@implementation FAVideoPlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}


- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayer *)player {
    return self.playerLayer.player;
}


@end
