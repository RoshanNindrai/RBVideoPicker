//
//  AwsUploadEngine.m
//  Uniq
//
//  Created by Roshan Balaji on 8/18/13.
//  Copyright (c) 2013 Uniq Labs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AwsUploadEngine.h"
#import "AwsConfig.h"

@interface AwsUploadEngine ()

@property(nonatomic, strong)AmazonS3Client *s3Client;

@end

@implementation AwsUploadEngine


-(AwsUploadEngine *)init
{
    
    self = [super init];
    if(self){
        
        self.s3Client = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        
    }
    
    return self;
    
}

+(AwsUploadEngine *)sharedAWSEngine
{
    
    static AwsUploadEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[self alloc] init];
    });
    return sharedEngine;

}

-(void)performAsynchronousVideoUpload:(NSData *)videoData
                              ofTitle:(NSString *)videoTitle
                       withCompletion:(void(^)(BOOL success))completion;

{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *put_obj_request = [[S3PutObjectRequest alloc] initWithKey:videoTitle
                                                                 inBucket:[AwsConfig videoBucket]] ;
        put_obj_request.contentType = @"video/mp4";
        put_obj_request.data        = videoData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3Client putObject:put_obj_request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                completion(NO);
            }
            else
            {
                completion(YES);
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(void)performAsynchronousImageUpload:(NSData *)imageData
                              ofTitle:(NSString *)pictureTitle
                       withCompletion:(void(^)(BOOL success))completion;
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *put_obj_request = [[S3PutObjectRequest alloc] initWithKey:pictureTitle
                                                                  inBucket:[AwsConfig pictureBucket]];
        put_obj_request.contentType = @"image/png";
        put_obj_request.data        = imageData;
        
        S3PutObjectResponse *putObjectResponse = [self.s3Client putObject:put_obj_request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                completion(NO);
            }
            else
            {
                
                completion(YES);
                
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
    });
}

@end
