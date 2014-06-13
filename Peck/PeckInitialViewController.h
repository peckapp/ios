//
//  PeckInitialViewController.h
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PeckInitialViewController : UIViewController <FBLoginViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
