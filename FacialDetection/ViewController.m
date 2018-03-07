//
//  ViewController.m
//  FacialDetection
//
//  Created by tom on 07/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "ViewController.h"
#import "TZAVCaptureSession.h"

@interface ViewController () <AVCaptureSessionDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [TZAVCaptureSession share].delegate_ = self;
    [self.mainView.layer addSublayer:[[TZAVCaptureSession share] layer]];
}

#pragma mark - AVCaptureSessionDelegate
- (void)imageFromSampleBuffer:(UIImage *(^)(void))handle {
    UIImage *image = handle();
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailView.image = image;
    });
}

@end
