 //
//  PhotomaniaURLPopupViewController.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotomaniaURLPopupViewController.h"

@interface PhotomaniaURLPopupViewController ()
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end

@implementation PhotomaniaURLPopupViewController

- (void) setUrl:(NSURL*) url {
    _url = url;
    [self updateUI];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void) updateUI {
    self.urlTextView.text = [self.url absoluteString];
}

@end
