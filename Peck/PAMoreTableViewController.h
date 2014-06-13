//
//  PAMoreTableViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PACoreDataProtocol.h"


@interface PAMoreTableViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate>{
    IBOutlet UIScrollView *scroller;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (nonatomic, retain) UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UITextField *facebookTextField;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@end
