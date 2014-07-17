//
//  PAProfileTableViewController2.m
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAProfileTableViewController2.h"
#import "PAAppDelegate.h"
#import "PASyncManager.h"

@interface PAProfileTableViewController2 ()

- (IBAction)createAccount:(id)sender;
- (IBAction)switchSchool:(id)sender;

@end

@implementation PAProfileTableViewController2

@synthesize profilePicture;
@synthesize emailTextField, twitterTextField, facebookTextField, infoTextView, firstNameTextField, lastNameTextField, passwordTextField;
int currentTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Profile";
    infoTextView.layer.borderWidth=.3f;
    infoTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    infoTextView.layer.cornerRadius = 8;
    
    self.firstNameTextField.delegate=self;
    self.lastNameTextField.delegate=self;
    self.emailTextField.delegate=self;
    self.passwordTextField.delegate=self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.firstNameTextField.text = [defaults objectForKey:@"first_name"];
    self.lastNameTextField.text = [defaults objectForKey:@"last_name"];
    self.emailTextField.text = [defaults objectForKey:@"email"];
    NSString*blurb = [defaults objectForKey:@"blurb"];
    NSLog(@"blurb: %@",blurb);
    self.infoTextView.text = [defaults objectForKey:@"blurb"];
    
    
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

#pragma mark - Account Creation and Configuration

- (IBAction)createAccount:(id)sender
{
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *loginRoot = [loginStoryboard instantiateInitialViewController];
    
    [self presentViewController:loginRoot animated:YES completion:nil];
}

- (IBAction)switchSchool:(id)sender
{
    PAAppDelegate *appDel = (PAAppDelegate*)[[UIApplication sharedApplication] delegate];
    UIViewController *configController = [appDel.mainStoryboard instantiateViewControllerWithIdentifier:@"configure"];
    
    [self presentViewController:configController animated:YES completion:nil];
}

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

#pragma mark - text field delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
        NSLog(@"next");
    }
    else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    else if(textField == self.emailTextField){
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField){
        [self.infoTextView becomeFirstResponder];
    }else{
        [self.infoTextView resignFirstResponder];
    }
    
    return NO;
}


#pragma mark - scroll view delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - table view deleagate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0 && indexPath.section==0){
        [self changePicture];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveChangesButton:(id)sender {
    //will post the new profile information to the server
    NSLog(@"change my profile");
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* institutionID = [defaults objectForKey:@"institution_id"];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    
    NSDictionary *updatedInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.emailTextField.text, @"email",
                                 self.firstNameTextField.text, @"first_name",
                                 self.lastNameTextField.text, @"last_name",
                                 self.infoTextView.text, @"blurb",
                                 self.passwordTextField.text,@"password",
                                 self.passwordTextField.text, @"password_confirmation",
                                 //userID, @"id",
                                 //institutionID, @"institution_id",
                                 nil];
    [[PASyncManager globalSyncManager] registerUserWithInfo:updatedInfo];
    
}
@end
