//
//  TZImageView.h
//  FacialDetection
//
//  Created by tom on 08/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZImageView : UIImageView
- (void)drawFaceWithRect:(CGRect)rect;
- (void)drawEyeLeftWithRect:(CGRect)rect;
- (void)drawEyeRightWithRect:(CGRect)rect;
- (void)drawNoseWithRect:(CGRect)rect;
- (void)drawMouseWithRect:(CGRect)rect;
@end
