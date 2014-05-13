//
//  RBViewController.m
//  RBVideoPickerDemo
//
//  Created by Roshan Balaji on 5/11/14.
//  Copyright (c) 2014 Uniq. All rights reserved.
//

#import "RBViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AwsUploadEngine.h"

@interface RBViewController ()

@end

@implementation RBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.picker = [[RBVideoPicker alloc] init];
    self.picker.delegate = self;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)starRecording:(id)sender {
    
       [self.picker startCaptureVideoOfQuality:RBLowVideoQuality];
}

-(void)videoController:(RBVideoPicker *)videoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSData *compressedVideo = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[info valueForKey:RBCompressedVideoMediaURL]]];
    
    NSLog(@"size after compression %lu", (unsigned long)[compressedVideo length]);
    [[AwsUploadEngine sharedAWSEngine] performAsynchronousVideoUpload:compressedVideo ofTitle:@"test.mp4" withCompletion:^(BOOL success){
        
        NSLog(@"upload result %d", success);
        
        
    }];
}

-(void)videoControllerDidCancel:(RBVideoPicker *)videoPicker
{

    

}

@end
