//
//  PAMoreTableViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAProfileTableViewController.h"

@interface PAProfileTableViewController ()

@end

@implementation PAProfileTableViewController

@synthesize profilePicture;
@synthesize scroller;
@synthesize emailTextField, twitterTextField, facebookTextField, infoTextView, nameTextField;
int currentTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Profile";
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (changePicture)];
    [profilePicture addGestureRecognizer:tapRecognizer];
    profilePicture.userInteractionEnabled = YES; // very important for UIImageView
    tapRecognizer.cancelsTouchesInView=NO;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView=NO;
    [self.scroller addGestureRecognizer:gestureRecognizer];

    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320, 1000)];
    infoTextView.layer.borderWidth=.5f;
    infoTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    infoTextView.layer.cornerRadius = 8;
    
    emailTextField.delegate = self;
    twitterTextField.delegate = self;
    facebookTextField.delegate = self;
    nameTextField.delegate = self;
    infoTextView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)changePicture{
    NSLog(@"changing picture");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                 delegate: self
                                                        cancelButtonTitle: @"Cancel"
                                                   destructiveButtonTitle: nil
                                                        otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
    [actionSheet showInView:self.view];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"picked photo");
    [self dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    profilePicture.image = image;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self takeNewPhotoFromCamera];
            break;
        case 1:
            [self choosePhotoFromExistingImages];
        default:
            break;
    }
}

- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
    }
}
-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
        
    }
}



- (void) hideKeyboard{
    if(currentTextField==0)
        [infoTextView resignFirstResponder];
    else{
        [self.scroller endEditing:NO];
    }
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField = (int)textField.tag;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self hideKeyboard];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [self hideKeyboard];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self hideKeyboard];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    currentTextField = 0;
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}
- (void)keyboardWasShown:(NSNotification *)notification {
    int widthOfText;
    int textFieldHeight;
    if(currentTextField==0){
        textFieldHeight = infoTextView.frame.origin.y;
        textFieldHeight+=infoTextView.frame.size.height;
        widthOfText=infoTextView.frame.size.height;
    }
    else{
        UITextField * tempTextField = (UITextField *) [self.scroller viewWithTag:currentTextField];
        textFieldHeight = tempTextField.frame.origin.y;
        widthOfText = tempTextField.frame.size.height;
        textFieldHeight+=widthOfText;
    }
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect screenRect = self.view.frame;
    
    CGPoint scrollPoint = CGPointMake(0.0, keyboardSize.height -(screenRect.size.height-textFieldHeight));
    
    int currentHeight = (int)[[scroller.layer presentationLayer] bounds].origin.y;

    int visibleHeight=screenRect.size.height - keyboardSize.height;
    if(textFieldHeight > (currentHeight+visibleHeight-widthOfText)){
        [self.scroller setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    //[self.scroller setContentOffset:CGPointZero animated:YES];
    
}

- (IBAction)saveChangesButton:(id)sender {
    //will post the new profile information to the server
    
}
@end
