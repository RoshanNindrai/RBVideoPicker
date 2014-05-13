//
//  RBVideoControllerDelegate.h
//  RBVideoCompressorDemo
//
//  Created by Roshan Balaji on 4/15/14.
//  Copyright (c) 2014 Uniq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBVideoPicker;

@protocol RBVideoControllerDelegate <NSObject>

-(void)videoController:(RBVideoPicker *)videoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info;


-(void)videoControllerDidCancel:(RBVideoPicker *)videoPicker;

@end
