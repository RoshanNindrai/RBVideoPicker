//
//  RBViewController.h
//  RBVideoPickerDemo
//
//  Created by Roshan Balaji on 5/11/14.
//  Copyright (c) 2014 Uniq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBVideoPicker.h"

@interface RBViewController : UIViewController<RBVideoControllerDelegate>

@property(nonatomic, strong)RBVideoPicker *picker;

@end
