//
//  UIImage+resize.h
//  FacialDetection
//
//  Created by tom on 14/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (resize)
- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)resizedImage:(CGSize)newSize

     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode

                                  bounds:(CGSize)bounds

                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize

                transform:(CGAffineTransform)transform

           drawTransposed:(BOOL)transpose

     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
@end
