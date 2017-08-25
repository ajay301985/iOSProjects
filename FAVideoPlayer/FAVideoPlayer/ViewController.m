//
//  ViewController.m
//  FAVideoPlayer
//
//  Created by Ajay Rawat on 12/07/17.
//  Copyright © 2017 Ajay Rawat. All rights reserved.
//

#import "ViewController.h"
#import "FAVideoManager.h"
#import "FAVideoData.h"
@import AVFoundation;
@import CoreMedia.CMTime;
@import Foundation;
#import "FAVideoCollectionViewCell.h"

static int AAPLPlayerViewControllerKVOContext = 0;

@import AVFoundation;

@interface ViewController ()

@property (nonatomic, retain) NSArray *videoDataArray;

@property (nonatomic, retain) NSMutableDictionary *imageDictionary;

@property (nonatomic, retain) AVQueuePlayer *player;

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

@property (nonatomic, retain) IBOutlet UISlider *timeSlider;

@property (nonatomic, retain) IBOutlet UILabel *startLabel;

@property (nonatomic, retain) IBOutlet UILabel *endTimeLabel;

@property (nonatomic, retain) IBOutlet UIButton *toggleButton;

@property (nonatomic, strong) id timeObserver;

@property (assign) NSInteger currentIndex;

@property CMTime currentTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"FAVideoCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"FAVideoCollectionViewCellIdentifier"];

    self.videoDataArray = [[FAVideoManager sharedInstance] videoDataArray];
    self.imageDictionary = [[NSMutableDictionary alloc] initWithCapacity:[self.videoDataArray count]];

    self.player = [[AVQueuePlayer alloc] init];

    [self addObserver:self forKeyPath:@"player.currentItem.duration"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:&AAPLPlayerViewControllerKVOContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    // [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)handleEnterForeground:(NSNotification*)notification {
    if (self.player.rate != 1.0) {
        [self.toggleButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
    } else {
        [self.toggleButton setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];
    }
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
        (NSTimeInterval)duration {
    // Fade the collectionView out
    [self.collectionView setAlpha:0.0f];

    // Suppress the layout errors by invalidating the layout
    [self.collectionView.collectionViewLayout invalidateLayout];

    // Calculate the index of the item that the collectionView is currently displaying
    CGPoint currentOffset = [self.collectionView contentOffset];
    self.currentIndex = currentOffset.x / self.collectionView.frame.size.width;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
    [self.collectionView setAlpha:1.0f];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.collectionView.collectionViewLayout invalidateLayout];
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
}

- (IBAction)togglePlayBackButton:(id)sender {
    UIButton *toggleButton = (UIButton *) sender;
    if (self.player.rate != 1.0) {
        [toggleButton setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];
        [self.player play];
    } else {
        // Playing; so pause.
        [toggleButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
        [self.player pause];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FAVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FAVideoCollectionViewCellIdentifier"
                                                                                forIndexPath:indexPath];
    FAVideoData *videoData = self.videoDataArray[indexPath.row];
    //this will start the image loading in bg

    cell.backgroundImageView.hidden = NO;
    //download and set the image as preview in background
    if (self.imageDictionary[videoData.imageUrl]) {
        UIImage *image = self.imageDictionary[videoData.imageUrl];
        cell.backgroundImageView.image = image;
    } else {
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:videoData.imageUrl]];
            if (imageData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *previewImage = [UIImage imageWithData:imageData];
                    self.imageDictionary[videoData.imageUrl] = previewImage;
                    cell.backgroundImageView.image = previewImage;
                });
            }
        });
    }
    return cell;
}

- (IBAction)timeSliderDidChange:(UISlider *)sender {
    self.currentTime = CMTimeMakeWithSeconds(sender.value, 1000);
    [self.player seekToTime:self.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [self scrollViewDidEndDecelerating:self.collectionView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"player.currentItem.duration"]) {
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double currentTime = hasValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;

        // Update timeSlider and enable/disable controls when duration > 0.0
        self.timeSlider.maximumValue = newDurationSeconds;
        self.timeSlider.value = currentTime;
        self.timeSlider.enabled = hasValidDuration;
        self.startLabel.text = [self createTimeString:currentTime];
        self.endTimeLabel.text = [self createTimeString:newDurationSeconds];
    }
}

- (NSString *)createTimeString:(double)time {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.second = (NSInteger) fmax(0.0, time);
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;

    return [formatter stringFromDateComponents:components];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //update video handling on scroll to positioin
    [self scrollViewDidEndDecelerating:scrollView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint centerPoint = CGPointMake(scrollView.center.x + scrollView.contentOffset.x,
            scrollView.center.y + scrollView.contentOffset.y);

    NSIndexPath *centerCellIndexPath = [self.collectionView indexPathForItemAtPoint:centerPoint];


    CMTime duration = [[self.player currentItem] duration];
    CMTime currentTime = [self.player currentTime];
    if (CMTIME_COMPARE_INLINE(currentTime, <, duration)) {
        FAVideoData *videoData = self.videoDataArray[self.currentIndex];
        videoData.currentTime = currentTime;
    } else {
        FAVideoData *videoData = self.videoDataArray[self.currentIndex];
        videoData.currentTime = kCMTimeZero;
    }

    self.currentIndex = centerCellIndexPath.row;

    //remove previous time observer to avoid periodic time observer multiple instanse
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }

    self.timeObserver = nil;
    FAVideoCollectionViewCell *currentVideoCell = (FAVideoCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:centerCellIndexPath];
    FAVideoPlayerView __weak *videoPlayer = [currentVideoCell playView];
    FAVideoData *videoData = self.videoDataArray[centerCellIndexPath.row];
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:videoData.videoUrl]];
    [self.player removeAllItems];
    AVPlayerItem *newPlayerItem = [AVPlayerItem playerItemWithAsset:asset];

    [self.player replaceCurrentItemWithPlayerItem:newPlayerItem];
    currentVideoCell.playView.playerLayer.player = self.player;
    [currentVideoCell.playView.playerLayer.player play];
    [self.toggleButton setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];

    CMTime currentItemDuration = [[self.player currentItem] duration];
    CMTime currentItemTime = [videoData currentTime];
    if (CMTIME_COMPARE_INLINE(currentItemTime, <, currentItemDuration)) {
        [currentVideoCell.playView.playerLayer.player seekToTime:currentItemTime];
    }

    ViewController __weak *weakSelf = self;

    self.timeObserver = [videoPlayer.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                queue:dispatch_get_main_queue()
                                      usingBlock:^(CMTime time) {
                                                                double timeElapsed = CMTimeGetSeconds(time);
                                                                weakSelf.timeSlider.value = timeElapsed;
                                                                CMTime duration = weakSelf.player.currentItem ? weakSelf.player.currentItem.duration : kCMTimeZero;
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    weakSelf.startLabel.text = [weakSelf createTimeString:timeElapsed];

                                                                    //hide background image view after some time once video start playing
                                                                    if (timeElapsed > 0.2) {
                                                                        [currentVideoCell.playView setHidden:NO];
                                                                        currentVideoCell.backgroundImageView.hidden = YES;
                                                                    }
                                                                });

                                                                CMTime currentTimeValue = [self.player currentTime];
                                                                //Check if current video end then start next video in queue
                                                                if (CMTIME_COMPARE_INLINE(currentTimeValue, >=, duration)) {
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        if (self.timeObserver) {
                                                                            [videoPlayer.player removeTimeObserver:self.timeObserver];
                                                                        }
                                                                        self.timeObserver = nil;
                                                                        FAVideoData *videoData = self.videoDataArray[self.currentIndex];
                                                                        videoData.currentTime = kCMTimeZero;

                                                                        NSInteger currentIndex1 = centerCellIndexPath.row + 1; //get index for next video
                                                                        if (currentIndex1 >= [self.videoDataArray count]) {
                                                                            return;
                                                                        }
                                                                        self.currentIndex = currentIndex1;
                                                                        //scroll to next index
                                                                        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex1
                                                                                                                                        inSection:0]
                                                                                                    atScrollPosition:UICollectionViewScrollPositionNone
                                                                                                            animated:YES];
                                                                    });
                                                                }

                                                            }];
}

@end
