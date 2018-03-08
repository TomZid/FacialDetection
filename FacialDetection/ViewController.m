//
//  ViewController.m
//  FacialDetection
//
//  Created by tom on 07/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "ViewController.h"
#import "TZAVCaptureSession.h"
#import "TZImageView.h"

@interface ViewController () <AVCaptureSessionDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet TZImageView *detailView;
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
    
    float x = arc4random() % 5 + 70;
    float y = arc4random() % 5 + 200;
    float width = arc4random() % 3 + 20;
    float height = arc4random() % 3 + 20;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.detailView drawFaceWithRect:CGRectMake(x - 20, y - 20, width + 100, height + 100)];
        [self.detailView drawEyeLeftWithRect:CGRectMake(x, y, width, height)];
        [self.detailView drawEyeRightWithRect:CGRectMake(x + 60, y, width, height)];
        [self.detailView drawNoseWithRect:CGRectMake(x + 30, y + 40, width, height)];
        [self.detailView drawMouseWithRect:CGRectMake(x + 20, y + 70, width + 30, height)];
    });


}

@end
