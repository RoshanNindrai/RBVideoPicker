//
//  RBVideoPicker.m
//  RBVideoPickerDemo
//
//  Created by Roshan Balaji on 5/11/14.
//  Copyright (c) 2014 Uniq. All rights reserved.
//

#import "RBVideoPicker.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "QuartzCore/QuartzCore.h"
#define TEMP_FILE_NAME @"temp.mp4"
#define TEMP_IMAGE_NAME @"tempimage"

@interface RBVideoPicker()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property(nonatomic, strong) NSDictionary *videoInfo;
@property(nonatomic, strong) AVAsset *videoAsset;
@property(nonatomic, strong) AVAssetWriter *videoWriter;
@property(nonatomic, strong) AVAssetReader *videoReader;
@property(nonatomic, strong) AVAssetReader *audioReader;
@property(nonatomic, strong) AVAssetWriterInput* videoWriterInput;
@property(nonatomic, strong) AVAssetReaderTrackOutput *videoReaderOutput;
@property(nonatomic, strong) AVAssetWriterInput* audioWriterInput;
@property(nonatomic, strong) AVAssetReaderOutput *audioReaderOutput;
@end



NSString * const RBCompressedVideoMediaURL = @"COMPRESSEDMEDIAURL";
NSString * const RBThumbnailImageURL = @"THUMBNAILIMAGE";
 static UIImagePickerController *videoRecorder;


@implementation RBVideoPicker

-(RBVideoPicker *)init
{
    self = [super init];
    if(self)
    {
        videoRecorder = [[UIImagePickerController alloc] init];
        videoRecorder.delegate = self;
        videoRecorder.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoRecorder.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,  nil];
        

        
    }
    //[self configureCameraSettings];
    return self;
    
}

-(void)configureCameraSettings
{
    
    if(!self.videoQuality)
        self.videoQuality = RBLowVideoQuality;
    
    switch (self.videoQuality) {
        case RBLowVideoQuality:
            videoRecorder.videoQuality = UIImagePickerControllerQualityType640x480;
            break;
        case RBMediumVideoQuality:
            videoRecorder.videoQuality = UIImagePickerControllerQualityTypeMedium;
            break;
        case RBHighVideoQuality:
            videoRecorder.videoQuality = UIImagePickerControllerQualityTypeHigh;
            break;
        default:
            break;
    }
    
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSData *original =  [[NSFileManager defaultManager] contentsAtPath:[info objectForKey:UIImagePickerControllerMediaURL]];
    
    NSLog(@"size before compression %lu", (unsigned long)[original length]);

    
    self.videoInfo = info;
    [videoRecorder dismissViewControllerAnimated:YES completion:^{
       
        [self.videoInfo setValue:[NSTemporaryDirectory()  stringByAppendingPathComponent:TEMP_FILE_NAME] forKey:RBCompressedVideoMediaURL];
        [self.videoInfo setValue:[NSTemporaryDirectory()  stringByAppendingPathComponent:TEMP_IMAGE_NAME] forKey:RBThumbnailImageURL];
        [self removeOldTempMediaFiles];
        [self compressVideoFromMedia];
        if(self.generateThumbnailImage){
            [self generateThumbnailImage:[info valueForKey:
                                          UIImagePickerControllerMediaURL] ofSize:self.thumbNailSize];
            
        }
    }];
    
    
   
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    NSLog(@"cancel");
    //[self.videoRecorder dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(void)startCaptureVideoOfQuality:(RBVideoQuality)videoQuality
{
    
    self.videoQuality = videoQuality;
    [self configureCameraSettings];
    [self.delegate presentViewController:videoRecorder animated:YES completion:nil];
    
    
}

#pragma video compression

-(void)compressVideoFromMedia
{
    
    @autoreleasepool {
        //setup video writer
        self.videoAsset = [[AVURLAsset alloc] initWithURL:[self.videoInfo valueForKey:UIImagePickerControllerMediaURL] options:nil];
        NSDictionary *videoWriterSettings = [self prepareVideoWritterSettings];
        [self prepareVideoWritterWithSettings:videoWriterSettings];
        [self prepareAudioWritter];
        [self compressVideo];
    
    }
}

-(NSDictionary *)prepareVideoWritterSettings
{
    
    AVAssetTrack *videoTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGSize videoSize = videoTrack.naturalSize;
    
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:960000], AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,
                                         AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey,
                                         [NSNumber numberWithFloat:videoSize.width], AVVideoWidthKey,
                                         [NSNumber numberWithFloat:videoSize.height], AVVideoHeightKey, nil];
    
    return videoWriterSettings;
    
}

-(void)prepareVideoWritterWithSettings:(NSDictionary *)videoWriterSettings
{
    
    AVAssetTrack *videoTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    self.videoWriterInput = [AVAssetWriterInput
                             assetWriterInputWithMediaType:AVMediaTypeVideo
                             outputSettings:videoWriterSettings];
    
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    
    self.videoWriterInput.transform = videoTrack.preferredTransform;
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:[self.videoInfo valueForKeyPath:RBCompressedVideoMediaURL]] fileType:AVFileTypeQuickTimeMovie error:nil];
    
    [self.videoWriter addInput:self.videoWriterInput];
    
    //setup video reader
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
                                                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    self.videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    
    self.videoReader = [[AVAssetReader alloc] initWithAsset:self.videoAsset error:nil];
    
    [self.videoReader addOutput:self.videoReaderOutput];
    
    
}

-(void)prepareAudioWritter
{
    //setup audio writer
    self.audioWriterInput = [AVAssetWriterInput
                             assetWriterInputWithMediaType:AVMediaTypeAudio
                             outputSettings:nil];
    
    self.audioWriterInput.expectsMediaDataInRealTime = YES;
    
    [self.videoWriter addInput:self.audioWriterInput];
    
    
    //setup audio reader
    AVAssetTrack* audioTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    self.audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    
    self.audioReader = [AVAssetReader assetReaderWithAsset:self.videoAsset error:nil];
    
    [self.audioReader addOutput:self.audioReaderOutput];
    
    [self.videoWriter startWriting];
    
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
     [self.videoReader startReading];
}

-(void)compressVideo
{

    dispatch_queue_t _processingQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
    [self.videoWriterInput requestMediaDataWhenReadyOnQueue:_processingQueue usingBlock:
     ^{
          CMSampleBufferRef sampleBuffer;
         
         while ([self.videoWriterInput isReadyForMoreMediaData]) {
             
            if ([self.videoReader status] == AVAssetReaderStatusReading) {
                 
                 if(![self.videoWriterInput isReadyForMoreMediaData])
                     continue;
                 
                 sampleBuffer = [self.videoReaderOutput copyNextSampleBuffer];
                 
                if(sampleBuffer){
                     [self.videoWriterInput appendSampleBuffer:sampleBuffer];
                       CFRelease(sampleBuffer);
                }
                
             } else {
                 
                 [self.videoWriterInput markAsFinished];
                 switch ([self.videoReader status]) {
                     case AVAssetReaderStatusReading:
                         // the reader has more for other tracks, even if this one is done
                         break;
                         
                     case AVAssetReaderStatusCompleted:
                    {
                        NSLog(@"video compresses");
                        [self compressAudio];
                         
                         break;
                     }
                     case AVAssetReaderStatusFailed:
                     {
                         [self.videoWriter cancelWriting];
                         break;
                     }
                 }
                 break;
             }
         }
     }
     ];
    
    
}




-(void)compressAudio
{
    

    if ([self.videoReader status] == AVAssetReaderStatusCompleted) {
        
        //start writing from audio reader
        [self.audioReader startReading];
        
       // [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
        
        dispatch_queue_t processingQueue = dispatch_queue_create("CompressionQueue2", NULL);
        
        [self.audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
            
            while (self.audioWriterInput.readyForMoreMediaData) {
                
                CMSampleBufferRef sampleBuffer = [self.audioReaderOutput copyNextSampleBuffer];
                
                if ([self.audioReader status] == AVAssetReaderStatusReading) {
                    
                    [self.audioWriterInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                }
                
                else {
                    
                    [self.audioWriterInput markAsFinished];
                    
                    if ([self.audioReader status] == AVAssetReaderStatusCompleted) {
                       
                       // [self.videoWriter endSessionAtSourceTime:kCMTimeZero];
                        [self.videoWriter finishWritingWithCompletionHandler:^(){
                            
                            NSLog(@"Finished");
                            [self.delegate videoController:self didFinishPickingMediaWithInfo:self.videoInfo];
                        }];
                        
                    }
                }
            }
            
        }];
        
    }
    
    
    
}

#pragma thumnail image generation

-(void) generateThumbnailImage:(NSURL *)inputURL ofSize:(CGSize)imageSize{
    
    NSParameterAssert(self.videoAsset);
    AVAssetImageGenerator *assetIG =
    [[AVAssetImageGenerator alloc] initWithAsset:self.videoAsset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    NSTimeInterval theTimeInterval = 0.0;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = theTimeInterval;
    NSError *igError = nil;
    thumbnailImageRef =
    [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                    actualTime:NULL
                         error:&igError];
    UIImage *thumbnailImage = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    
    CGSize newSize = (CGSizeEqualToSize(imageSize, CGSizeZero)) ? CGSizeMake(178.0f, 235.0f) : imageSize;
    
    UIGraphicsBeginImageContext(newSize);
    [thumbnailImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self saveImage:newImage];
    
}

-(void)saveImage:(UIImage *)image{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = UIImagePNGRepresentation(image);
    [fileManager createFileAtPath:[self.videoInfo valueForKey:RBThumbnailImageURL] contents:data attributes:nil];
    
}

-(void)removeOldTempMediaFiles
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:[self.videoInfo valueForKey:RBCompressedVideoMediaURL]];
    if(fileExists){
        
        [fileManager removeItemAtURL:[NSURL fileURLWithPath:[self.videoInfo valueForKey:RBCompressedVideoMediaURL]] error:&error];
        if(error){
            
            NSLog(@"Error: while clearing temp memory %@", error.description);
            
        }
        
    }
    
}



@end

