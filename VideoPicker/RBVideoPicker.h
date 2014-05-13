//
//  RBVideoPicker.h
//  RBVideoPickerDemo
//
//  Created by Roshan Balaji on 5/11/14.
//  Copyright (c) 2014 Uniq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBVideoControllerDelegate.h"

typedef enum {
    
    RBLowVideoQuality,
    RBMediumVideoQuality,
    RBHighVideoQuality
    
}RBVideoQuality;

typedef enum {
    
    RBAWSUploadEngine,
    
}RBVideoUploadEngine;

extern NSString * const RBCompressedVideoMediaURL;
extern NSString * const RBThumbnailImageURL;

@interface RBVideoPicker : NSObject

@property(nonatomic, weak)UIViewController<RBVideoControllerDelegate>* delegate;
@property(nonatomic) RBVideoQuality videoQuality;
@property(nonatomic) RBVideoUploadEngine uploadEngine;
@property(nonatomic, strong) UIView * cameraOverlayView;
@property(nonatomic) BOOL generateThumbnailImage;
@property(nonatomic) CGSize thumbNailSize;

-(void)startCaptureVideoOfQuality:(RBVideoQuality)videoQuality;

@end

