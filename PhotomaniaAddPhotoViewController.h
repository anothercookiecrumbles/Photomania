//
//  PhotomaniaAddPhotoViewController.h
//  Photomania
//
//  Created by Priyanjana Bengani on 28/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer.h"
#import "Photo.h"

@interface PhotomaniaAddPhotoViewController : UIViewController

@property (strong,nonatomic) Photographer* photographerTakingPhoto;
@property (strong,nonatomic, readonly) Photo* addedPhoto;

@end
