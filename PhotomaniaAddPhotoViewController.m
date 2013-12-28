//
//  PhotomaniaAddPhotoViewController.m
//  Photomania
//
//  Created by Priyanjana Bengani on 28/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotomaniaAddPhotoViewController.h"
#import "Photo.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+CS193p.h"

@interface PhotomaniaAddPhotoViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) NSURL* imageUrl;
@property (nonatomic, strong) NSURL* thumbnailUrl;
@property (nonatomic, strong, readwrite) Photo* addedPhoto;
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation PhotomaniaAddPhotoViewController

- (IBAction)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto {
}

@synthesize image=_image;

- (void) setImage:(UIImage *)image {
    self.imageView.image = image;
    [[NSFileManager defaultManager] removeItemAtURL:_imageUrl error:NULL];
    _imageUrl = nil;
}

- (UIImage*) image {
    return self.imageView.image;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // keyboard disappears when you hit return.
    return YES;
}

+ (BOOL) canAddPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString*)kUTTypeImage]) {
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
    return NO;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.image = [UIImage imageNamed:@"flower.jpg"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[self class] canAddPhoto]) {
     //   [self fatalAlert:@"This device cannot add a photo. Uh-oh!"];
    }
    else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation]; // clean-up!
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Do Add Photo"]) {
        NSManagedObjectContext* context = self.photographerTakingPhoto.managedObjectContext;
        if (context) {
            Photo* photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.title = self.titleTextField.text;
            photo.subtitle = self.subtitleTextField.text;
            photo.whoTook = self.photographerTakingPhoto;
            photo.latitude = @(self.location.coordinate.latitude);
            photo.longitude = @(self.location.coordinate.longitude);
            photo.imageUrl = [self.imageUrl absoluteString];
            photo.thumbnailURL = [self.thumbnailUrl absoluteString];
            
            self.addedPhoto = photo;
        }
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"Do Add Photo"]) {
        if (!self.imageView.image) {
            [self alert:@"No photo taken."];
            return NO;
        }
        else if (![self.titleTextField.text length]) {
            [self alert:@"Title field is blank."];
            return NO;
        }
        else {
            return YES;
        }
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void) alert:(NSString*) message {
    [[[UIAlertView alloc] initWithTitle:@"Add Photo"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void) fatalAlert:(NSString*) message {
    [[[UIAlertView alloc] initWithTitle:@"Add Photo"
                                message:message
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self cancel];
}

- (CLLocationManager*) locationManager {
    if (!_locationManager) {
        CLLocationManager* locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = [locations lastObject];
}

- (NSURL*) imageUrl {
    if (!_imageUrl && self.imageView.image) {
        NSURL* url = [self uniqueDocumentUrl];
        if (url) {
            NSData* imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageUrl = url;
            }
        }
    }
    return _imageUrl;
}

- (NSURL*) thumbnailUrl {
    NSURL* url = [self.imageUrl URLByAppendingPathExtension:@"thumbnail"];
    if (![_thumbnailUrl isEqual:url]) {
        _thumbnailUrl = nil;
        if (url) {
            UIImage* thumbnail = [self.image imageByScalingToSize:CGSizeMake(75,75)];
            NSData* imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([imageData writeToURL:url atomically:YES]) {
                _thumbnailUrl = url;
            }
        }
    }
    return _thumbnailUrl;
}

- (NSURL*) uniqueDocumentUrl {
    NSArray* documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask];
    NSString* unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

@end
