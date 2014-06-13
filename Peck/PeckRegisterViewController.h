//
//  PeckRegisterViewController.h
//  PeckDev
//
//  Created by Aaron Taylor on 3/15/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeckRegisterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *registerItems;
@property (strong, nonatomic) NSMutableArray *userRegistrationItems;
@end
