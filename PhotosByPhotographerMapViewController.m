//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import <MapKit/MapKit.h>
#import "Photo+Annotation.h"
#import "ImaginariumImageViewController.h"
#import "Photographer+Create.h"
#import "PhotomaniaAddPhotoViewController.h"

@interface PhotosByPhotographerMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButtonItem;
@property (nonatomic,strong) NSArray* photosByPhotographer;
@property (nonatomic,strong) ImaginariumImageViewController* imageViewController;
@end

@implementation PhotosByPhotographerMapViewController

- (ImaginariumImageViewController*) imageViewController {
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController*) detailvc).viewControllers firstObject];
    }
    return [detailvc isKindOfClass:[ImaginariumImageViewController class]] ? detailvc : nil;
}

- (void) setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
}

- (void) setPhotographer:(Photographer *)photographer {
    _photographer = photographer;
    self.title = photographer.name;
    _photosByPhotographer = nil; // must reset, else lazy instantiation will not happen.
    [self updateMapViewAnnotations];
    [self updateAddPhotoBarButtonItem];
}

- (void) updateAddPhotoBarButtonItem {
    if (self.addPhotoBarButtonItem) {
        BOOL canAddPhoto = self.photographer.isUser;
        NSMutableArray* rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!rightBarButtonItems) rightBarButtonItems = [NSMutableArray new];
        NSUInteger addPhotoBarButtonItemIndex = [rightBarButtonItems indexOfObject:self.addPhotoBarButtonItem];
        if (addPhotoBarButtonItemIndex == NSNotFound) {
            if (canAddPhoto) [rightBarButtonItems addObject:self.addPhotoBarButtonItem];
        }
        else {
            if (!canAddPhoto) [rightBarButtonItems removeObjectAtIndex:addPhotoBarButtonItemIndex];
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}

- (NSArray*) photosByPhotographer {
    if (!_photosByPhotographer) {
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@",self.photographer];
        _photosByPhotographer = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _photosByPhotographer;
}

- (void) updateMapViewAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByPhotographer];
    [self.mapView showAnnotations:self.photosByPhotographer animated:YES];
    
    if (self.imageViewController) {
        Photo* autoselectedPhoto = [self.photosByPhotographer firstObject];
        if (autoselectedPhoto) {
            [self.mapView selectAnnotation:autoselectedPhoto animated:YES];
            [self prepareViewController:self.imageViewController forSegue:nil toShowAnnotation:autoselectedPhoto];
        }
    }
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* reuseId = @"PhotosByPhotographerMapViewController";
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view){
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        if (!self.imageViewController) {
            view.canShowCallout = YES;
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
            view.leftCalloutAccessoryView = imageView;
        
            UIButton* disclosureButton = [[UIButton alloc] init];
            [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
            [disclosureButton sizeToFit];
            view.rightCalloutAccessoryView = disclosureButton;
        }
        
    }
    
    view.annotation = annotation;
    
    return view;
}

- (void) updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView*) annotationView {
    UIImageView* view = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        view = (UIImageView*) annotationView.leftCalloutAccessoryView;
    }
    
    if (view) {
        Photo* photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo*) annotationView.annotation;
        }
        
        if (photo){
            view.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];
        }
    }
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.imageViewController) {
        [self prepareViewController:self.imageViewController forSegue:nil toShowAnnotation:view.annotation];
    }
    else {
        [self updateLeftCalloutAccessoryViewInAnnotationView:view];
    }
}

// Segue via code, instead of via the Storyboard.
- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"Show Photo" sender:view];
}

- (void) prepareViewController:(id) vc forSegue:(NSString*) segueIdentifier toShowAnnotation:(id <MKAnnotation>) annotation {
    Photo* photo = nil;
    if ([annotation isKindOfClass:[Photo class]]) {
        photo = (Photo*) annotation;
    }
    
    if (photo) {
        if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photo"]) {
            if ([vc isKindOfClass:[ImaginariumImageViewController class]]) {
                ImaginariumImageViewController* ivc = (ImaginariumImageViewController*) vc;
                ivc.imageUrl = [NSURL URLWithString:photo.imageUrl];
                ivc.title = photo.title;
            }
        }
    }
}

// unwinding, i.e. when we hit cancel on the modal segue, this should be invoked.
- (IBAction)addedPhoto:(UIStoryboardSegue*) segue {
    if ([segue.sourceViewController isKindOfClass:[PhotomaniaAddPhotoViewController class]]) {
        PhotomaniaAddPhotoViewController* apvc = (PhotomaniaAddPhotoViewController*) segue.sourceViewController;
        Photo* addedPhoto = apvc.addedPhoto;
        if (addedPhoto) {
            [self.mapView addAnnotation:addedPhoto];
            [self.mapView showAnnotations:@[addedPhoto] animated:YES];
            self.photosByPhotographer = nil;
        }
        else {
            NSLog(@"No photo added, but we're trying to unwind!");
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotomaniaAddPhotoViewController class]]) {
        PhotomaniaAddPhotoViewController* apvc = (PhotomaniaAddPhotoViewController*) segue.destinationViewController;
        apvc.photographerTakingPhoto = self.photographer; // check for isUser as well?
    }
    else if ([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController forSegue:segue.identifier toShowAnnotation:((MKAnnotationView*)sender).annotation];
    }
}

@end
