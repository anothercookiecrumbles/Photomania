//
//  Photo+Annotation.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)

- (CLLocationCoordinate2D) coordinate {
    CLLocationCoordinate2D c;
    
    c.latitude = [self.latitude doubleValue];
    c.longitude = [self.longitude doubleValue];
    
    return c;
}

@end
