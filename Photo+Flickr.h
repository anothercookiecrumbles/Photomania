//
//  Photo+Flickr.h
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo*) photoWithFlickrInfo:(NSDictionary*) photoDictionary inManagedObjectContext:(NSManagedObjectContext*) context;
+ (void) loadPhotosFromFlickrArray:(NSArray*) photos inManagedObjectContext:(NSManagedObjectContext*) context;

@end
