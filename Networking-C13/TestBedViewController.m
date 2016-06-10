//
//  TestBedViewController.m
//  Networking-C13
//
//  Created by 张保国 on 16/6/4.
//  Copyright © 2016年 BobZhang. All rights reserved.
//

#import "TestBedViewController.h"
#import "Utility.h"
#import "UIView+AutoLayout.h"

#pragma mark - TBVC_01_ReachAbility

#import "UIDevice+Reachability.h"

@interface TBVC_01_ReachAbility ()<ReachAbilityWatcher>
@end

@implementation TBVC_01_ReachAbility
{
    UITextView *textView;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 24.0f : 12.0f];
    textView.textColor = COOKBOOK_PURPLE_COLOR;
    textView.text = @"";
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(runTests));
}


- (void)log:(id)formatstring,...
{
    va_list arglist;
    if (!formatstring) return;
    va_start(arglist, formatstring);
    NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *newString = [NSString stringWithFormat:@"%@\n%@: %@", textView.text, [NSDate date], outstring];
        textView.text = newString;
        [textView scrollRangeToVisible:NSMakeRange(newString.length, 1)];
    }];
}

// Run basic reachability tests
- (void)runTests
{
    // Many of the following reachability tests can block.  In your production code, they should not be run in the main thread.
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         UIDevice *device = [UIDevice currentDevice];
         [self log:@"\n\nReachability Tests"];
         [self log:@"Current host: %@", [device hostname]];
         [self log:@"Local WiFi IP: %@", [device localWiFiIPAddress]];
         [self log:@"All WiFi IP: %@", [device localWiFiIPAddresses]];
         
         [self log:@"Network available?: %@", [device networkAvailable] ? @"Yes" : @"No"];
         [self log:@"Active WLAN?: %@", [device activeWLAN] ? @"Yes" : @"No"];
         [self log:@"Active WWAN?: %@", [device activeWWAN] ? @"Yes" : @"No"];
         [self log:@"Active hotspot?: %@", [device activePersonalHotspot] ? @"Yes" : @"No"];
         
         [self checkAddresses];
     }];
}

- (void)checkAddresses
{
    UIDevice *device = [UIDevice currentDevice];
    if (![device networkAvailable]) return;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"\n\nChecking IP Addresses"];
         }];
         NSString *google = [device getIPAddressForHost:@"www.google.com"];
         NSString *amazon = [device getIPAddressForHost:@"www.amazon.com"];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"Google: %@", google];
             [self log:@"Amazon: %@", amazon];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
             [self checkSites];
         }];
     }];
}

- (void)checkSite:(NSString *)urlString
{
    UIDevice *device = [UIDevice currentDevice];
    [self log:@"• %@ : %@", urlString, [device hostAvailable:urlString] ? @"available" : @"not available"];
}

// Note, if your ISP redirects unavailable sites to their own servers, these will give false positives.
- (void)checkSites
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         NSDate *date = [NSDate date];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"\n\nChecking Site Availability"];
         }];
         NSOperationQueue * siteCheckOperationQueue = [[NSOperationQueue alloc] init];
         [siteCheckOperationQueue addOperationWithBlock:^{
             [self checkSite:@"www.google.com"];
             [self checkSite:@"www.ericasadun.com"];
             [self checkSite:@"www.notverylikely.com"];
             [self checkSite:@"192.168.0.108"];
             [self checkSite:@"pearson.com"];
             [self checkSite:@"www.pearson.com"];
         }];
         [siteCheckOperationQueue waitUntilAllOperationsAreFinished];
         
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"Elapsed time: %0.1f", [[NSDate date] timeIntervalSinceDate:date]];
         }];
     }];
}

- (void)reachAbilityChanged
{
    [self log:@"\n\n**** REACHABILITY CHANGED! ****"];
    [self runTests];
}

@end

#pragma mark - TBVC_04_BackgroundTransfers

@import MediaPlayer;
// Large Movie (35 MB)
#define LARGE_MOVIE @"http://www.archive.org/download/BettyBoopCartoons/Betty_Boop_More_Pep_1936_512kb.mp4"

// Short movie (3 MB)
#define SMALL_MOVIE @"http://www.archive.org/download/Drive-inSaveFreeTv/Drive-in--SaveFreeTv_512kb.mp4"

// Fake address
#define FAKE_MOVIE @"http://www.idontbelievethisisavalidurlforthisexample.com"

// Current URL to test
#define MOVIE_URL   [NSURL URLWithString:LARGE_MOVIE]

// Location to copy the downloaded item
#define FILE_LOCATION	[NSHomeDirectory() stringByAppendingString:@"/Documents/Movie.mp4"]


@interface TBVC_04_BackgroundTransfers ()<NSURLSessionDownloadDelegate>
@end

@implementation TBVC_04_BackgroundTransfers {
    BOOL success;
    MPMoviePlayerViewController *player;
    UIProgressView *progressView;
    NSURLSession *session;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor magentaColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Download Movie", @selector(startDownload));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Exit App", @selector(exitApp));
    
    // Create a session configuration passing in the session ID
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"CoreiOSBackgroundID"];
    // ?
    configuration.discretionary = YES;
    
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:progressView];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [progressView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(200, 10, 10, 10) excludingEdge:ALEdgeBottom];
    
    self.statusLabel = [UILabel newAutoLayoutView];
    self.statusLabel.text = @"Not Started";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    [self.statusLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:progressView withOffset:10 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.statusLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    
}

- (void)startDownload{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [player.moviePlayer stop];
    player = nil;
    
    // Remove any existing data
    if ([[NSFileManager defaultManager] fileExistsAtPath:FILE_LOCATION])
    {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:FILE_LOCATION error:&error])
            NSLog(@"Error removing existing data: %@", error.localizedFailureReason);
    }
    
    // Fetch the data
    [self downloadMovie:MOVIE_URL];

}

- (void)downloadMovie:(NSURL *)url{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.statusLabel.text = @"Download Started";
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}

- (void)exitApp
{
    abort();
}

- (void)play{
    player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:FILE_LOCATION]];
    [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    player.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    player.moviePlayer.allowsAirPlay = YES;
    [player.moviePlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:player.moviePlayer queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
    
    player.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentMoviePlayerViewControllerAnimated:player];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:FILE_LOCATION] error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:FILE_LOCATION]];
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Play", @selector(play));
        self.statusLabel.text = @"Download Completed";
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressView setProgress:progress animated:YES];
        self.statusLabel.text = @"Download Progressing...";
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error)
        {
            NSLog(@"Task %@ failed: %@", task, error);
            self.statusLabel.text = @"Download Failed";
        }
        else
        {
            NSLog(@"Task %@ completed", task);
            [progressView setProgress:1 animated:NO];
            self.statusLabel.text = @"Download Completed";
        }
    });

}
@end


