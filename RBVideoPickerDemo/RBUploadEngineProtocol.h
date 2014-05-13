//
//  RBUploadEngineProtocol.h
//  RBImagePickerDemo
//
//  Created by Roshan Balaji on 5/13/14.
//  Copyright (c) 2014 Uniq Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RBUploadEngineProtocol <NSObject>

-(void)performAsynchronousVideoUpload:(NSData *)videoData ofTitle:(NSString *)videoTitle withCompletion:(void(^)(BOOL success))completion;

-(void)performAsynchronousImageUpload:(NSData *)imageData ofTitle:(NSString *)pictureTitle withCompletion:(void(^)(BOOL success))completion;;


@end
