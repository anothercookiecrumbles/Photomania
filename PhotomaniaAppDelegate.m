#import "PhotomaniaAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotomaniaAppDelegate+MOC.h"
#import "PhotoDatabaseAvailability.h"

@interface PhotomaniaAppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@end

#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

@implementation PhotomaniaAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    self.photoDatabaseContext = [self createMainQueueManagedObjectContext];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self startFlickrFetch];
    return YES;
}

- (void) setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext {
    _photoDatabaseContext = photoDatabaseContext;
    
    [NSTimer scheduledTimerWithTimeInterval:20*60 target:self selector:NSSelectorFromString(@"startFlickrFetch:") userInfo:nil repeats:YES];
    
    NSDictionary* userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext: self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
}

- (void)startFlickrFetch {
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (NSURLSession *)flickrDownloadSession {
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _flickrDownloadSession;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        NSManagedObjectContext* context = self.photoDatabaseContext;
        if (context) {
            NSArray* photos = [self flickrPhotosAtURL:localFile];
            [context performBlock:^{
                [Photo loadPhotosFromFlickrArray:photos inManagedObjectContext:context];
                [context save:NULL];
            }];
        }
        else {
            [self flickrDownloadTasksMightBeComplete];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

#pragma background fetch
- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self startFlickrFetch];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

@end