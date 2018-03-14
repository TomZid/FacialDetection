//
//  TZAVCaptureSession.m
//  FacialDetection
//
//  Created by tom on 07/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "TZAVCaptureSession.h"

#define SW [UIScreen mainScreen].bounds.size.width
static TZAVCaptureSession *a = nil;

@interface TZAVCaptureSession ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
}
@end

@implementation TZAVCaptureSession
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        a = [super allocWithZone:zone];
        [a initialSession];
    });
    return a;
}

+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        a = [[super alloc] init];
    });
    return a;
}

- (void)initialSession {
    _captureSession = [[AVCaptureSession alloc] init];
    {
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    AVCaptureDevice *videoCaptureDevice = ({
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *v = nil;
        AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        for (AVCaptureDevice *cam in deviceSession.devices) {
            if (cam.position == AVCaptureDevicePositionFront)
                v = cam;
        }
        v;
    });
    NSError *error = nil;

    //input
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if (videoInput) {
        [_captureSession addInput:videoInput];
    }
    else {
        // Handle the failure.
    }

    dispatch_queue_t _videoQueue = dispatch_queue_create("com.faceDet", NULL);
    //  output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    {
        AVCaptureConnection *videoCon = [output connectionWithMediaType:AVMediaTypeVideo];
        if ([videoCon isVideoOrientationSupported]) {
            videoCon.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
    }
    [output setSampleBufferDelegate:self queue:_videoQueue];
    output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    output.alwaysDiscardsLateVideoFrames = NO;

    {
//        AVCaptureDeviceFormat *bestFormat = nil;
//        AVFrameRateRange *bestFrameRateRange = nil;
//        for (AVCaptureDeviceFormat *format in [videoCaptureDevice formats]) {
//            for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
//                NSLog(@"range.maxFrameRate is: %f", range.maxFrameRate);
//                if (range.maxFrameRate == 60) {
//                    bestFormat = format;
//                    bestFrameRateRange = range;
//                }
//            }
//        }
//        if (bestFormat) {
//            NSError *error = nil;
//            if ([videoCaptureDevice lockForConfiguration:&error]) {
//                videoCaptureDevice.activeFormat = bestFormat;
//                videoCaptureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 1);
//                videoCaptureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 1);
//                [videoCaptureDevice unlockForConfiguration];
//            }
//        }

        CGFloat desiredFPS = 1.0;
        AVCaptureDeviceFormat *selectedFormat = nil;
        int32_t maxWidth = 0;
        AVFrameRateRange *frameRateRange = nil;
        for (AVCaptureDeviceFormat *format in [videoCaptureDevice formats]) {
            for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
                CMFormatDescriptionRef desc = format.formatDescription;
                CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
                int32_t width = dimensions.width;
                if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                    selectedFormat = format;
                    frameRateRange = range;
                    maxWidth = width;
                }
            }
        }
        if (selectedFormat) {
            if ([videoCaptureDevice lockForConfiguration:nil]) {
                videoCaptureDevice.activeFormat = selectedFormat;
                videoCaptureDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
                videoCaptureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
                [videoCaptureDevice unlockForConfiguration];
            }
        }
    }

    if ([_captureSession canAddOutput:output]) {
        [_captureSession addOutput:output];
    }

    [_captureSession startRunning];
}

- (AVCaptureVideoPreviewLayer*)layer {
    if (nil == _videoPreviewLayer) {
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_videoPreviewLayer setFrame:CGRectMake(0, 0, SW, SW)];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _videoPreviewLayer;
}

#pragma mark - Custom Action
- (UIImage*)imageFromBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);

    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);

    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    //    image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationLeft];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);

    CVPixelBufferUnlockBaseAddress(buffer, 0);

    CGSize size = {image.size.height, image.size.width};
    image = [self reverseImageByScalingToSize:size :image];

    return image;
}

-(UIImage*)reverseImageByScalingToSize:(CGSize)targetSize:(UIImage*)anImage {
    UIImage* sourceImage = anImage;
    CGFloat targetWidth = targetSize.height;
    CGFloat targetHeight = targetSize.width;

    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);

    if (bitmapInfo == kCGImageAlphaNone)
    {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }

    CGContextRef bitmap;

    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown)
    {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth,
                                       CGImageGetBitsPerComponent(imageRef),
                                       CGImageGetBytesPerRow(imageRef),
                                       colorSpaceInfo,
                                       bitmapInfo);
    }
    else
    {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight,
                                       CGImageGetBitsPerComponent(imageRef),
                                       CGImageGetBytesPerRow(imageRef),
                                       colorSpaceInfo,
                                       bitmapInfo);
    }

    CGFloat (^radians)(CGFloat) = ^(CGFloat angle) {
        return M_PI / 180  * angle;
    };

    if (sourceImage.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
    }
    else if (sourceImage.imageOrientation == UIImageOrientationLeft)
    {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
    }
    else if (sourceImage.imageOrientation == UIImageOrientationDown)
    {
        // NOTHING
    }
    else if (sourceImage.imageOrientation == UIImageOrientationUp)
    {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
    }

    //    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetHeight, targetWidth), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];

    CGContextRelease(bitmap);
    CGImageRelease(ref);

    return newImage;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        UIImage *image = [self imageFromBuffer:sampleBuffer];
        if (self.delegate_) {
            [self.delegate_ imageFromSampleBuffer:^UIImage *{
                return image;
            }];
        }
    }
}

@end
