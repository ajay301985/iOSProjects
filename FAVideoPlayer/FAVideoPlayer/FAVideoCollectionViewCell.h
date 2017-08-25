//
//  FAVideoCollectionViewCell.h
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 16/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAVideoPlayerView.h"

@interface FAVideoCollectionViewCell : UICollectionViewCell

@property (nonatomic,retain) IBOutlet FAVideoPlayerView *playView;

@property (nonatomic,retain) IBOutlet UIImageView *backgroundImageView;

@end
