//
//  FAVideoManager.h
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 12/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAVideoManager : NSObject

@property (nonatomic,retain) NSArray *videoDataArray;

- (void)loadVideoData;

+ (FAVideoManager *)sharedInstance;

@end
