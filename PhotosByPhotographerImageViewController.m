//
//  PhotosByPhotographerImageViewController.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotosByPhotographerImageViewController.h"
#import "PhotosByPhotographerMapViewController.h"

@interface PhotosByPhotographerImageViewController ()
@property (nonatomic,strong) PhotosByPhotographerMapViewController* mapvc;
@end

@implementation PhotosByPhotographerImageViewController

- (void) setPhotographer:(Photographer *)photographer {
    _photographer = photographer;
    self.title = photographer.name;
    self.mapvc.photographer = self.photographer;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotosByPhotographerMapViewController class]]) {
        PhotosByPhotographerMapViewController* mvc = (PhotosByPhotographerMapViewController*) segue.destinationViewController;
        mvc.photographer = self.photographer;
        self.mapvc = mvc;
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end
