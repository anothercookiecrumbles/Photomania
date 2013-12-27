//
//  ImaginariumImageViewController.m
//  Imaginarium
//
//  Created by Priyanjana Bengani on 23/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "ImaginariumImageViewController.h"
#import "PhotomaniaURLPopupViewController.h"

@interface ImaginariumImageViewController () <UIScrollViewAccessibilityDelegate,UISplitViewControllerDelegate>
@property (nonatomic,strong) UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,strong) UIImage* image;
@property (weak,nonatomic) PhotomaniaURLPopupViewController* urlPopupController;
@end

@implementation ImaginariumImageViewController

- (void) setImageUrl:(NSURL *)imageUrl {
    _imageUrl = imageUrl;
   // self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageUrl]]; //If this URL is on the WWW, it will block; if it's a local file, we should be fine.
    [self startDownloadingImage];
}

- (void) startDownloadingImage {
    self.image = nil;
    if (self.imageUrl) {
        [self.spinner startAnimating];
        NSURLRequest* request = [NSURLRequest requestWithURL:self.imageUrl];
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration]; // ideally should use backgroundSessionConfiguration.
        NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask* task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL* localFile, NSURLResponse* response, NSError* error) {
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageUrl]) {
                                                                    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                                                    dispatch_async(dispatch_get_main_queue(),^{ self.image = image; });
                                                                   // [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO]; (alternatively...)
                                                                }
                                                            }
        }];
        [task resume];
    }
}

- (void) awakeFromNib {
    self.splitViewController.delegate = self;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
}

- (UIImageView*) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void) setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    if (self.image) {
        self.scrollView.contentSize = self.image.size;
    }
    else {
        self.scrollView.contentSize = CGSizeZero;
    }
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// I don't need a synthesize image as I never use the image instance variable.

- (UIImage*) image {
    return self.imageView.image;
}

- (void) setImage:(UIImage *)image {
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
   // [self.imageView sizeToFit];
    self.imageView.frame = CGRectMake(0,0,image.size.width,image.size.height);
    if (self.image) {
        self.scrollView.contentSize = self.image.size;
    }
    else {
        self.scrollView.contentSize = CGSizeZero;
    }
    [self.spinner stopAnimating];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotomaniaURLPopupViewController class]]) {
        PhotomaniaURLPopupViewController* urlvc = (PhotomaniaURLPopupViewController*) segue.destinationViewController;
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*) segue;
            self.urlPopupController = (PhotomaniaURLPopupViewController*) popoverSegue.popoverController;
        }
        urlvc.url = self.imageUrl;
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"Show URL"]) {
        return self.urlPopupController ? NO : (self.imageUrl ? YES : NO);
    }
    else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

@end
