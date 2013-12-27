//
//  PhotomaniaAppDelegate.h
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"

@interface PhotomaniaAppDelegate (MOC)
- (void) saveContext:(NSManagedObjectContext*) context;
- (NSManagedObjectContext*) createMainQueueManagedObjectContext;
@end
