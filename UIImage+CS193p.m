//
//  UIImage+CS193p.m
//  Photomania
//
//  Created by Priyanjana Bengani on 28/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "UIImage+CS193p.h"

@implementation UIImage (CS193p)

- (UIImage*) imageByScalingToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage*) imageByApplyingFilterNamed:(NSString *)filterName {
    UIImage* filteredImage = self;
    // Step 1: create CImage Object
    CIImage *inputImage = [CIImage imageWithCGImage:[self CGImage]];
    if (inputImage) {
        // Step 2: get the filter
        CIFilter* filter = [CIFilter filterWithName:filterName];
        // Step 3: provide arguments
        [filter setValue:inputImage forKey:kCIInputImageKey];
        // Step 4: get output image
        CIImage* outputImage = [filter outputImage];
        if (outputImage) {
            filteredImage = [UIImage imageWithCIImage:outputImage];
            if (filteredImage) {
                // Step 5: draw it into new image
                UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
                [filteredImage drawAtPoint:CGPointZero];
                filteredImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }
    return filteredImage;
}

@end
