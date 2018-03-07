//
//  TZAVCaptureSession.h
//  FacialDetection
//
//  Created by tom on 07/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AVCaptureSessionDelegate
- (void)imageFromSampleBuffer:(UIImage*(^)(void))handle;
@end

@interface TZAVCaptureSession : NSObject
+ (instancetype)share;
- (AVCaptureVideoPreviewLayer*)layer;

@property (nonatomic, weak) id<AVCaptureSessionDelegate> delegate_;

@end
