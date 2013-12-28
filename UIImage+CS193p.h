//
//  UIImage+CS193p.h
//  Photomania
//
//  Created by Priyanjana Bengani on 28/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CS193p)
- (UIImage*) imageByScalingToSize:(CGSize) size;
- (UIImage*) imageByApplyingFilterNamed:(NSString*) filterName;
@end
