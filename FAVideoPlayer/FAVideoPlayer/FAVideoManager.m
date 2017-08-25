//
//  FAVideoManager.m
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 12/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import "FAVideoManager.h"
#import "FAVideoData.h"

@implementation FAVideoManager

+ (FAVideoManager *)sharedInstance {
    static FAVideoManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FAVideoManager alloc] init];
    });

    return sharedInstance;
}

- (void)loadVideoData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *videoDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    NSArray *videos = videoDict[@"videos"];
    NSMutableArray *dataArray = [NSMutableArray new];
    for (NSDictionary *videoDict in videos) {
        FAVideoData *videoData = [[FAVideoData alloc] init];
        videoData.videoUrl = videoDict[@"videoURL"];
        videoData.imageUrl = videoDict[@"imageURL"];
        [dataArray addObject:videoData];
    }

    self.videoDataArray = [NSMutableArray arrayWithArray:dataArray];
}


@end
