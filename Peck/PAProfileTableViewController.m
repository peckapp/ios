//
//  PAProfileTableViewController2.m
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAProfileTableViewController.h"
#import "PAAppDelegate.h"
#import "PASyncManager.h"
#import "PAFetchManager.h"
#import "PAAssetManager.h"
#import "PAInitialViewController.h"
#import "PAFriendProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PAChangePasswordViewController.h"

@interface PAProfileTableViewController ()

- (IBAction)login:(id)sender;

- (IBAction)registerAccount:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;

@end

@implementation PAProfileTableViewController

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
    
    self.feedbackLabel.textColor = [[PAAssetManager sharedManager] lightColor];
    
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePicture)];
    tapRecognizer.cancelsTouchesInView = NO;
    [profilePicture addGestureRecognizer:tapRecognizer];
    profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
    profilePicture.clipsToBounds = YES;
    profilePicture.userInteractionEnabled = YES;
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    //[appdelegate setProfileViewController:self];
    [appdelegate setProfileProperty:self];
    
    NSLog(@"Finished viewDidLoad (PAProfileTableViewController)");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.firstNameTextField.text = [defaults objectForKey:@"first_name"];
    self.lastNameTextField.text = [defaults objectForKey:@"last_name"];
    self.emailTextField.text = [defaults objectForKey:@"email"];
    //NSString*blurb = [defaults objectForKey:@"blurb"];
    //NSLog(@"blurb: %@",blurb);
    self.infoTextView.text = [defaults objectForKey:@"blurb"];
    
    NSURL* url = [NSURL URLWithString:[defaults objectForKey:@"profile_picture_url"]];
    if(url){
        [self.profilePicture setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]];
    }else{
        self.profilePicture.image =[UIImage imageNamed:@"profile-placeholder.png"];
    }
    
    if([defaults objectForKey:@"authentication_token"]){
        loggedIn=YES;
        NSLog(@"logged in");
        self.loginButton.title =@"Logout";
        self.registerButton.title = @"Save";
        self.registerButton.action = @selector(saveChangesButton:);
    }
    else{
        loggedIn=NO;
        NSLog(@"logged out");
        self.loginButton.title = @"Login";
        self.registerButton.title = @"Register";
        self.registerButton.action = @selector(registerAccount:);
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
     else if([[segue identifier] isEqualToString:@"changePassword"]){
         PAChangePasswordViewController* destination = [segue destinationViewController];
         destination.tempPass = self.tempPass;
         self.tempPass=nil;
     }
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 

#pragma mark - Account Creation and Configuration

- (IBAction)login:(id)sender
{
    if(!loggedIn){
        
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UINavigationController *loginRoot = [loginStoryboard instantiateInitialViewController];
        PAInitialViewController* root = loginRoot.viewControllers[0];
        root.direction = @"none";
        [self presentViewController:loginRoot animated:YES completion:nil];
    }else{
        //Logging out the user
        
        
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        if(appdelegate.circleViewController.selectedIndexPath){
            //if there is a currently expanded cell, we must condense this cell before logging out
            
            PACircleCell* cell = (PACircleCell*)[appdelegate.circleViewController.tableView cellForRowAtIndexPath:appdelegate.circleViewController.selectedIndexPath];
            
            [appdelegate.circleViewController condenseCircleCell:cell atIndexPath:appdelegate.circleViewController.selectedIndexPath];
        }

        
        [[PASyncManager globalSyncManager] logoutUser];
        
        [[PAFetchManager sharedFetchManager] logoutUser];
        
        if (FBSession.activeSession.state == FBSessionStateOpen|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        }
        
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"authentication_token"];
        [defaults removeObjectForKey:@"first_name"];
        [defaults removeObjectForKey:@"last_name"];
        [defaults removeObjectForKey:@"blurb"];
        [defaults removeObjectForKey:@"email"];
        [defaults removeObjectForKey:@"profile_picture_url"];
        [defaults removeObjectForKey:@"home_institution"];
        
        
        [defaults setObject:@NO forKey:@"logged_in"];
        
        [[PASyncManager globalSyncManager] ceateAnonymousUser:nil];
        
        self.emailTextField.text=@"";
        self.firstNameTextField.text=@"";
        self.infoTextView.text = @"";
        self.lastNameTextField.text = @"";
        self.profilePicture.image = [UIImage imageNamed:@"profile-placeholder.png"];
        self.loginButton.title = @"Login";
        self.registerButton.title = @"Register";
        self.registerButton.action = @selector(registerAccount:);
        
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

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 30.0f;
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0 && indexPath.row==5){
        NSLog(@"view the user's profile");
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navController = [loginStoryboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
        [self presentViewController:navController animated:YES completion:nil];
    }else if(indexPath.section==0 && indexPath.row==6){
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *feedbackController = [loginStoryboard instantiateViewControllerWithIdentifier:@"sendFeedback"];
        [self presentViewController:feedbackController animated:YES completion:nil];
    }
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
