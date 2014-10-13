//
//  PANestedInfoViewController.m
//  
//
//  Created by Aaron Taylor on 10/12/14.
//
//

#import "PANestedInfoViewController.h"
#import "PANestedInfoViewControllerPrivate.h"
#import "PAAssetManager.h"
#import "UIImageView+AFNetworking.h"
#import "PASyncManager.h"
#import "PAMethodManager.h"

#define separatorWidth 0.5

@interface PANestedInfoViewController ()

// default separators to deliniate cell divisions. to be turned off for cells that display pictures
@property (strong, nonatomic) CALayer *upperSeparator;
@property (strong, nonatomic) CALayer *lowerSeparator;

@end

@implementation PANestedInfoViewController

-(void)viewDidLoad {
    self.attendImage = [UIImage imageNamed:@"attend_icon"];
    self.nullAttendImage = [UIImage imageNamed:@"null_attend_icon"];
    
    self.upperSeparator = [[CALayer alloc] init];
    [self.upperSeparator setBackgroundColor:[[[PAAssetManager sharedManager] lightColor] CGColor]];
    self.lowerSeparator = [[CALayer alloc] init];
    [self.lowerSeparator setBackgroundColor:[[[PAAssetManager sharedManager] lightColor] CGColor]];
}

// show and hide the image separators
-(void) showSeparators {
    [self.view.layer addSublayer:self.upperSeparator];
    self.upperSeparator.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.origin.y, self.view.layer.frame.size.width, separatorWidth);
    
    [self.view.layer addSublayer:self.lowerSeparator];
    self.lowerSeparator.frame = CGRectMake(self.view.layer.frame.origin.x, self.blurredImageView.layer.frame.size.height - separatorWidth, self.view.layer.frame.size.width, separatorWidth);
}
-(void) hideSeparators {
    [self.upperSeparator removeFromSuperlayer];
    
    [self.lowerSeparator removeFromSuperlayer];
}

// sets up clean image and blurred image for the cell
-(void)configureView {
    
    __weak typeof(self) weakSelf = self; // to avoid retain cycles
    // setting the blurred image for when the cell is compressed
    NSURL* blurredImageURL = [NSURL URLWithString:[self.detailItem valueForKey:@"blurredImageURL"]];
    __weak UIImageView* weakBlurredImageView = self.blurredImageView;
    [self.blurredImageView setImageWithURLRequest:[NSURLRequest requestWithURL:blurredImageURL]
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              [UIView beginAnimations:@"fade in blurred image" context:nil];
                                              [UIView setAnimationDuration:1.0];
                                              
                                              [weakSelf hideSeparators];
                                              weakBlurredImageView.image = image;
                                              
                                              [UIView commitAnimations];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              
                                          }];
    
    
    NSURL* cleanImageURL = [NSURL URLWithString:[self.detailItem valueForKey:@"imageURL"]];
    __weak UIImageView* weakCleanImageView = self.cleanImageView;
    [self.cleanImageView setImageWithURLRequest:[NSURLRequest requestWithURL:cleanImageURL]
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            [UIView beginAnimations:@"fade in clean image" context:nil];
                                            [UIView setAnimationDuration:1.0];
                                            
                                            weakCleanImageView.image = image;
                                            
                                            [UIView commitAnimations];
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            
                                        }];
}


-(void) configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - PANestedCellControllerProtocol (unimplemented declarations)

-(void)setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject {
    
}

-(void)compressAnimated:(BOOL)animated {
    
}

-(void)expandAnimated:(BOOL)animated {
    
}

-(UIView*) viewForBackButton {
    return nil;
}

#pragma mark - Webservice interaction

-(void)postComment:(NSString *)text withCategory:(NSString*)category
{
    
    if(![text isEqualToString:@""]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authentication_token"]){
            if([[defaults objectForKey:@"institution_id"] integerValue]==[[defaults objectForKey:@"home_institution"]integerValue]){
                self.commentText=nil;
                /*
                 NSIndexPath* firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:firstCellIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                 */
                
                NSLog(@"post comment");
                //NSString *commentText = cell.commentTextView.text;
                //cell.commentTextView.text=@"";
                
                NSNumber *userID = [defaults objectForKey:@"user_id"];
                NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
                
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            text, @"content",
                                            userID, @"user_id",
                                            category, @"category",
                                            [self.detailItem valueForKey:@"id" ],@"comment_from",
                                            institutionID, @"institution_id",
                                            nil];
                
                [[PASyncManager globalSyncManager] postComment:dictionary];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Foreign Institution" message:@"Please switch to your home institution to post comments" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        }else{
            [[PAMethodManager sharedMethodManager] showRegisterAlert:@"post a comment" forViewController:self];
        }
        
    }
}

#pragma mark - Text Fields

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)keyboardWasHidden:(NSNotification*)notification
{
    
    NSLog(@"after the keyboard was hidden, the y is %f", self.keyboardAccessoryView.frame.origin.y);
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"keyboard will show");
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardAccessoryView.frame = CGRectOffset(self.keyboardAccessoryView.frame, 0, -keyboardSize.height);
    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - self.postButton.frame.size.width - 7, 30);
    self.postButton.alpha = 1;
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardAccessoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.keyboardAccessory.frame = CGRectInset(self.keyboardAccessoryView.bounds, 7, 7);
    self.postButton.alpha = 0;
    
    NSLog(@"height of the view %f", self.view.frame.size.height);
    NSLog(@"keyboard y %f", self.keyboardAccessoryView.frame.origin.y);
    
    NSLog(@"actual keyboard frame %@", NSStringFromCGRect(self.keyboardAccessory.frame));
    
    [UIView commitAnimations];
}

- (BOOL)textViewIsSmallerThanFrame:(NSString*)text{
    _textViewHelper.frame = CGRectMake(0, 0, 222, 0);
    [_textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [_textViewHelper setHidden:YES];
    _textViewHelper.text = text;
    [_textViewHelper sizeToFit];
    if(_textViewHelper.frame.size.height>defaultCommentCellHeight){
        return NO;
    }
    return YES;
}

#pragma mark - Commenting

- (void)didSelectPostButton:(id)sender
{
    [self postComment:self.keyboardAccessory.text withCategory:self.category];
    [self.keyboardAccessory resignFirstResponder];
    self.keyboardAccessory.text = @"";
}


@end
