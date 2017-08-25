//
//  FAVideoData.h
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 12/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMedia.CMTime;

@interface FAVideoData : NSObject

@property(nonatomic,retain) NSString *videoUrl;

@property(nonatomic,retain) NSString *imageUrl;

@property(nonatomic,assign) CMTime currentTime;

@end
