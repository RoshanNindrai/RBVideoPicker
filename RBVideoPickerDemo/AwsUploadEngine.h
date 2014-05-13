//
//  AwsUploadEngine.h
//  Uniq
//
//  Created by Roshan Balaji on 8/18/13.
//  Copyright (c) 2013 Uniq Labs. All rights reserved.
//

#import <AWSS3/AWSS3.h>
#import "RBUploadEngineProtocol.h"
#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>

@interface AwsUploadEngine : NSObject<RBUploadEngineProtocol>


+(AwsUploadEngine *)sharedAWSEngine;

@end
