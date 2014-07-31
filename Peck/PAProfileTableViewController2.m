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
#import "PAFetchManager.h"

@interface PAProfileTableViewController2 ()

- (IBAction)login:(id)sender;

- (IBAction)registerAccount:(id)sender;

@end

@implementation PAProfileTableViewController2

@synthesize profilePicture;
@synthesize emailTextField, twitterTextField, facebookTextField, infoTextView, firstNameTextField, lastNameTextField;
int currentTextField;
BOOL loggedIn;

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
    
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePicture)];
    tapRecognizer.cancelsTouchesInView = NO;
    [profilePicture addGestureRecognizer:tapRecognizer];
    profilePicture.userInteractionEnabled = YES;
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
    self.profilePicture.image = [UIImage imageWithContentsOfFile:[defaults objectForKey:@"profile_picture"]];
    
    if([defaults objectForKey:@"authentication_token"]){
        loggedIn=YES;
        NSLog(@"logged in");
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    else{
        loggedIn=NO;
        NSLog(@"logged out");
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
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

 #pragma mark - Navigation
 
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     
     if([[segue identifier] isEqualToString:@"showSubscriptions"]){
         NSLog(@"update subscriptions");
         
     }
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 

#pragma mark - Account Creation and Configuration

- (IBAction)login:(id)sender
{
    if(!loggedIn){
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *loginRoot = [loginStoryboard instantiateInitialViewController];
        [self presentViewController:loginRoot animated:YES completion:nil];
    }else{
        [[PAFetchManager sharedFetchManager] logoutUser];
        
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"authentication_token"];
        [defaults removeObjectForKey:@"first_name"];
        [defaults removeObjectForKey:@"last_name"];
        [defaults removeObjectForKey:@"blurb"];
        [defaults removeObjectForKey:@"email"];
        [defaults removeObjectForKey:@"profile_picture"];
        
        [defaults setObject:@NO forKey:@"logged_in"];
        
        self.emailTextField.text=@"";
        self.firstNameTextField.text=@"";
        self.infoTextView.text = @"";
        self.lastNameTextField.text = @"";
        self.profilePicture.image = nil;
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        loggedIn=NO;
    }
}

- (IBAction)registerAccount:(id)sender {
    NSLog(@"reg");
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *registerControllet = [loginStoryboard instantiateViewControllerWithIdentifier:@"register"];
    [self presentViewController:registerControllet animated:YES completion:nil];
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
    }else if (textField == self.lastNameTextField) {
        [self.infoTextView becomeFirstResponder];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return NO;
}


#pragma mark - scroll view delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - table view deleagate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /*if(indexPath.row==1 && indexPath.section==0){
        [self switchSchool:self];
    }*/
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveChangesButton:(id)sender {
    //will post the new profile information to the server
    NSLog(@"change my profile");
    
    NSDictionary *updatedInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.emailTextField.text, @"email",
                                 self.firstNameTextField.text, @"first_name",
                                 self.lastNameTextField.text, @"last_name",
                                 self.infoTextView.text, @"blurb",
                                 nil];
    
    
    // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSData* data = UIImageJPEGRepresentation(self.profilePicture.image, .5);
    
    
    [[PASyncManager globalSyncManager] updateUserWithInfo:updatedInfo withImage:data];
    
}
@end
