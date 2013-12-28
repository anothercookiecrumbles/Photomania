//
//  Photographer+Create.h
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer*) userInManagedObjectContext:(NSManagedObjectContext*) context;

- (BOOL) isUser;

+ (Photographer*) photographerWithName:(NSString*) name inManagedObjectContext:(NSManagedObjectContext*) context;

@end
