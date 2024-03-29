/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */


// Constants used to represent your AWS Credentials.
#define ACCESS_KEY_ID          @"AKIAIAYP3RABDP3BEIMA"
#define SECRET_KEY             @"RYwIxveSw0FDMKg6qPqHqIfXSMv6/iPorGpqSj0J"


// Constants for the Bucket and Object name.
#define PICTURE_BUCKET         @"picturebucket"
#define VIDEO_BUCKET           @"uniq_video"

#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."


@interface AwsConfig:NSObject {
}

/**
 * Utility method to create a bucket name using the Access Key Id.  This will help ensure uniqueness.
 */
+(NSString *)pictureBucket;

+(NSString *)videoBucket;


@end
