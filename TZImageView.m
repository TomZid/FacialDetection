//
//  TZImageView.m
//  FacialDetection
//
//  Created by tom on 08/03/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "TZImageView.h"

typedef void(^ResizeRectHandler)(CGRect);

@interface TZImageView ()
@property (nonatomic, strong) CAShapeLayer *faceLayer;
@property (nonatomic, strong) CAShapeLayer *eyeLeftLayer;
@property (nonatomic, strong) CAShapeLayer *eyeRightLayer;
@property (nonatomic, strong) CAShapeLayer *noseLayer;
@property (nonatomic, strong) CAShapeLayer *mouthLayer;
@end

@implementation TZImageView
{
    ResizeRectHandler _faceResizeHandler;
    ResizeRectHandler _eyeLeftResizeHandler;
    ResizeRectHandler _eyeRightResizeHandler;
    ResizeRectHandler _noseResizeHandler;
    ResizeRectHandler _mouseResizeHandler;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak typeof(self) ws = self;
    _faceResizeHandler = ^(CGRect rect) {
        if (ws.faceLayer == nil) {
            _faceLayer = [CAShapeLayer new];
            [ws.layer addSublayer:ws.faceLayer];
        }
        ws.faceLayer.strokeColor = [UIColor blackColor].CGColor;
        ws.faceLayer.fillColor = [UIColor clearColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path setLineWidth:5];
        ws.faceLayer.path = path.CGPath;
    };
    _eyeLeftResizeHandler = ^(CGRect rect) {
        if (ws.eyeLeftLayer == nil) {
            ws.eyeLeftLayer = [CAShapeLayer new];
            [ws.layer addSublayer:ws.eyeLeftLayer];
        }
        ws.eyeLeftLayer.strokeColor = [UIColor blackColor].CGColor;
        ws.eyeLeftLayer.fillColor = [UIColor clearColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path setLineWidth:5];
        ws.eyeLeftLayer.path = path.CGPath;
    };
    _eyeRightResizeHandler = ^(CGRect rect) {
        if (ws.eyeRightLayer == nil) {
            ws.eyeRightLayer = [CAShapeLayer new];
            [ws.layer addSublayer:ws.eyeRightLayer];
        }
        ws.eyeRightLayer.strokeColor = [UIColor blackColor].CGColor;
        ws.eyeRightLayer.fillColor = [UIColor clearColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path setLineWidth:5];
        ws.eyeRightLayer.path = path.CGPath;
    };
    _noseResizeHandler = ^(CGRect rect) {
        if (ws.noseLayer == nil) {
            ws.noseLayer = [CAShapeLayer new];
            [ws.layer addSublayer:ws.noseLayer];
        }
        ws.noseLayer.strokeColor = [UIColor blackColor].CGColor;
        ws.noseLayer.fillColor = [UIColor clearColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path setLineWidth:5];
        ws.noseLayer.path = path.CGPath;
    };
    _mouseResizeHandler = ^(CGRect rect) {
        if (ws.mouthLayer == nil) {
            ws.mouthLayer = [CAShapeLayer new];
            [ws.layer addSublayer:ws.mouthLayer];
        }
        ws.mouthLayer.strokeColor = [UIColor blackColor].CGColor;
        ws.mouthLayer.fillColor = [UIColor clearColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path setLineWidth:5];
        ws.mouthLayer.path = path.CGPath;
    };
}

- (void)drawFaceWithRect:(CGRect)rect {
    if (_faceResizeHandler) {
        _faceResizeHandler(rect);
    }
}

- (void)drawEyeLeftWithRect:(CGRect)rect {
    if (_eyeLeftResizeHandler) {
        _eyeLeftResizeHandler(rect);
    }
}

- (void)drawEyeRightWithRect:(CGRect)rect {
    if (_eyeRightResizeHandler) {
        _eyeRightResizeHandler(rect);
    }
}

- (void)drawNoseWithRect:(CGRect)rect {
    if (_noseResizeHandler) {
        _noseResizeHandler(rect);
    }
}

- (void)drawMouseWithRect:(CGRect)rect {
    if (_mouseResizeHandler) {
        _mouseResizeHandler(rect);
    }
}

@end
