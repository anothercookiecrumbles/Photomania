//
//  Photographer+Create.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer*) photographerWithName:(NSString*) name inManagedObjectContext:(NSManagedObjectContext*) context {
    Photographer* photographer = nil;
    
    if ([name length]) {
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name=%@",name];
        
        NSError* error;
        NSArray* matches = [context executeFetchRequest:request error:&error];
        if (!matches || error || ([matches count] > 1)) {
            NSLog(@"Error retrieving photographer.");
        }
        else if (![matches count]) {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
            photographer.name = name;
        }
        else {
            photographer = [matches lastObject];
        }
    }
    
    return photographer;
}

+ (Photographer*) userInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self photographerWithName:@" My Photos" inManagedObjectContext:context]; // This is awful! Using a space to ensure sorting. 
}

- (BOOL) isUser {
    return  self == [[self class] userInManagedObjectContext:self.managedObjectContext];
}

@end
