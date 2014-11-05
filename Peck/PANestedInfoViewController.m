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
#import "PAFetchManager.h"
#import "UIImageView+AFNetworking.h"
#import "PASyncManager.h"
#import "PAMethodManager.h"
#import "PACommentCell.h"

#define separatorWidth 0.5

@interface PANestedInfoViewController ()

// default separators to deliniate cell divisions. to be turned off for cells that display pictures
@property (strong, nonatomic) CALayer *upperSeparator;
@property (strong, nonatomic) CALayer *lowerSeparator;

@end

@implementation PANestedInfoViewController

-(void)viewDidLoad {
    // Date formatter for the full date indicator
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
    
    // Images to indicate attendance status
    self.attendImage = [UIImage imageNamed:@"attend_icon"];
    self.nullAttendImage = [UIImage imageNamed:@"null_attend_icon"];
    
    // Separators that are used to delineate Cells without images
    self.upperSeparator = [[CALayer alloc] init];
    [self.upperSeparator setBackgroundColor:[[[PAAssetManager sharedManager] lightColor] CGColor]];
    self.lowerSeparator = [[CALayer alloc] init];
    [self.lowerSeparator setBackgroundColor:[[[PAAssetManager sharedManager] lightColor] CGColor]];
    
    self.textViewHelper = [[UITextView alloc] init];
    [self.textViewHelper setHidden:YES];
    
    self.heightDictionary = [[NSMutableDictionary alloc] init];
    
    self.view.backgroundColor = [[PAAssetManager sharedManager] darkColor];
    
    self.headerView = [[UIView alloc] init];
    self.footerView = [[UIView alloc] init];
    self.imagesView = [[UIView alloc] init];
    
    self.cleanImageView = [[UIImageView alloc] init];
    self.cleanImageView.contentMode = UIViewContentModeCenter;
    [self.imagesView addSubview:self.cleanImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeCenter;
    [self.imagesView addSubview:self.blurredImageView];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.blurredImageView addSubview:self.timeLabel];
    
    [self.headerView addSubview:[[PAAssetManager sharedManager] createShadowWithFrame:CGRectMake(0, -64, self.view.frame.size.width, 64) top:YES]];

    self.fullTitleLabel = [[UILabel alloc] init];
    self.fullTitleLabel.textColor = [UIColor whiteColor];
    self.fullTitleLabel.font = [UIFont boldSystemFontOfSize:21.0];
    self.fullTitleLabel.numberOfLines = 0;
    [self.headerView addSubview:self.fullTitleLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    [self.headerView addSubview:self.dateLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = [UIFont systemFontOfSize:13.0];
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.numberOfLines = 0;
    [self.headerView addSubview:self.descriptionLabel];
    
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.imagesView];
    
    self.attendingIcon = [[UIImageView alloc] initWithImage:self.nullAttendImage];
    self.attendingIcon.userInteractionEnabled = NO;
    [self.blurredImageView addSubview:self.attendingIcon];
    
    self.attendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.attendButton addTarget:self action:@selector(attendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.attendButton setTitle:@"Attend" forState:UIControlStateNormal];
    [self.headerView addSubview:self.attendButton];
    
    self.attendeesLabel = [[UILabel alloc] init];
    self.attendeesLabel.font = [UIFont systemFontOfSize:14.0];
    [self.headerView addSubview:self.attendeesLabel];
    
    self.keyboardAccessoryView = [[UIView alloc] init];
    self.keyboardAccessoryView.backgroundColor = [UIColor whiteColor];
    
    self.keyboardAccessory = [[PAAssetManager sharedManager] createTextFieldWithFrame:CGRectZero];
    self.keyboardAccessory.placeholder = @"Post a comment...";
    self.keyboardAccessory.delegate = self;
    
    [self.keyboardAccessoryView addSubview:self.keyboardAccessory];
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.postButton addTarget:self action:@selector(didSelectPostButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardAccessoryView addSubview:self.postButton];
    self.postButton.alpha = 0;
    
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(changeFirstResponder)
     name:UIKeyboardDidShowNotification
     object:nil];
     */
    
    [self.tableView reloadData];
    
    [self showSeparators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    initialFrame = self.tableView.frame;
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.keyboardAccessory resignFirstResponder];
    [self deregisterFromKeyboardNotifications];
}


-(void)updateFrames {
    
    self.imagesView.frame = CGRectMake(0, 0, self.view.frame.size.width, compressedHeight);
    self.cleanImageView.frame = self.imagesView.frame;
    self.blurredImageView.frame = self.imagesView.frame;
    
    
    // This is code that the subclasses have in common, but the interleaving dependencies make it tough to move things into here
    
//    CGFloat attendIconSize = self.blurredImageView.frame.size.height * attendIconRatio;
//    CGFloat attendX = self.timeLabel.frame.origin.x + 0.5*self.timeLabel.frame.size.width;
//    CGFloat attendY = self.timeLabel.frame.origin.y + 0.2*self.blurredImageView.frame.size.height;
//    CGRect attendRect = CGRectMake(attendX, attendY, attendIconSize, attendIconSize);
//    self.attendingIcon.frame = attendRect;
//    
//    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, imageHeight);
//    NSLog(@"headerView: %@", NSStringFromCGRect(self.headerView.frame));
//    self.dateLabel.frame = CGRectInset(self.headerView.frame, buffer, buffer);
//    [self.dateLabel sizeToFit];
//    
//    
//    self.attendButton.frame = CGRectMake(dateLabelDivide, 0, self.view.frame.size.width - dateLabelDivide, 50);
//    self.attendeesLabel.frame = CGRectMake(self.view.frame.size.width - 20, 0, 20, 50);
//    
//    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMaxY(self.descriptionLabel.frame) + buffer);
//    
//    self.footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 1000);
//    self.footerView.backgroundColor = [UIColor whiteColor];
//    
//    self.keyboardAccessoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
//    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - 14, 30);
//    self.postButton.frame = CGRectMake(self.keyboardAccessoryView.frame.size.width - self.keyboardAccessoryView.frame.size.height, 0, self.keyboardAccessoryView.frame.size.height, self.keyboardAccessoryView.frame.size.height);
//    
//    [self.keyboardAccessory resignFirstResponder];
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



#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //self.keyboardAccessoryView.frame = CGRectMake(0, scrollView.contentOffset.y + self.view.frame.size.height - self.keyboardAccessoryView.frame.size.height, self.keyboardAccessoryView.frame.size.width, self.keyboardAccessoryView.frame.size.height);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /*
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
     PACommentCell *cell = (PACommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
     [cell.commentTextView resignFirstResponder];
     */
    [self.keyboardAccessory resignFirstResponder];
}

# pragma mark - TableView actions
- (void)expandTableViewCell:(PACommentCell *)cell {
    self.textViewHelper.frame = cell.commentTextView.frame;
    self.textViewHelper.text = cell.commentTextView.text;
    
    [self.textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [self.textViewHelper sizeToFit];
    
    float newHeight = self.textViewHelper.frame.size.height;
    NSLog(@"new height: %f", newHeight);
    NSNumber *height = [NSNumber numberWithFloat: defaultCommentCellHeight];
    if(self.textViewHelper.frame.size.height + self.textViewHelper.frame.origin.y > defaultCommentCellHeight){
        height = [NSNumber numberWithFloat:self.textViewHelper.frame.size.height + self.textViewHelper.frame.origin.y];
    }
    //Comment* comment = _fetchedResultsController.fetchedObjects[cell.tag];
    
    NSString * commentID = [cell.commentID stringValue];
    
    [self.heightDictionary setValue:height forKey:commentID];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    
    //cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCommentCellHeight);
    //Comment *comment = _fetchedResultsController.fetchedObjects[cell.tag];
    NSString *commentID = [cell.commentID stringValue];
    [self.heightDictionary removeObjectForKey:commentID];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark - User Actions

- (IBAction)attendButton:(id)sender {
    if([self.attendButton.titleLabel.text isEqualToString:@"Attend"]){
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authentication_token"]){
            NSLog(@"attend the event");
            NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [defaults objectForKey:@"user_id"],@"user_id",
                                      [defaults objectForKey:@"institution_id"],@"institution_id",
                                      [self.detailItem valueForKey:@"id"],@"event_attended",
                                      self.category, @"category",
                                      [defaults objectForKey:@"user_id"], @"added_by",
                                      nil];
            
            [[PASyncManager globalSyncManager] attendEvent:attendee forViewController:self];
        }else{
            [[PAMethodManager sharedMethodManager] showRegisterAlert:@"attend an event" forViewController:self];
        }
    }else{
        NSLog(@"unattend the event");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self.detailItem valueForKey:@"id"], @"event_attended",
                                  [defaults objectForKey:@"institution_id"],@"institution_id",
                                  [defaults objectForKey:@"user_id"],@"user_id",
                                  self.category, @"category",
                                  nil];
        
        [[PASyncManager globalSyncManager] unattendEvent: attendee forViewController:self];
        
    }
    [self reloadAttendeeLabels];
}

#pragma mark Commenting

- (void)didSelectPostButton:(id)sender {
    [self postComment:self.keyboardAccessory.text withCategory:self.category];
    [self.keyboardAccessory resignFirstResponder];
    self.keyboardAccessory.text = @"";
}

#pragma mark - helpers for configureView

-(BOOL)userHasLikedComment:(Comment*)comment{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [[defaults objectForKey:@"user_id"] integerValue];
    for(int i = 0; i < [comment.likes count];i++){
        if(userID==[comment.likes[i] integerValue]){
            return YES;
        }
    }return NO;
}

-(NSString*)nameLabelTextForComment:(Comment*)comment{
    NSString* text = @"Unknown";
    if(comment.peer_id){
        Peer* tempPeer = [[PAFetchManager sharedFetchManager] getPeerWithID:comment.peer_id];;
        if(tempPeer){
            text=tempPeer.name;
        }
    }
    
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"comment id: %@ my id: %@",comment.peer_id, [defaults objectForKey:@"user_id"]);
    if([[defaults objectForKey:@"user_id"] integerValue]==[comment.peer_id integerValue]){
        text = [[defaults objectForKey:@"first_name"] stringByAppendingString:@" "];
        text = [text stringByAppendingString:[defaults objectForKey:@"last_name"]];
    }
    text = [text stringByAppendingString:@" "];
    text = [text stringByAppendingString:[self dateToString:comment.created_at]];
    
    return text;
}

-(UIImageView *)imageViewForComment:(Comment*)comment {
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSURL* imageURL;
    if([[defaults objectForKey:@"user_id"] integerValue]==[comment.peer_id integerValue]){
        //return [[UIImageView alloc] initWithImage:self.userPicture];
        imageURL = [NSURL URLWithString:[defaults objectForKey:@"profile_picture_url"]];
    } else {
        Peer * commentFromPeer = [[PAFetchManager sharedFetchManager] getPeerWithID:comment.peer_id];
        if(commentFromPeer.imageURL){
            imageURL = [NSURL URLWithString:commentFromPeer.imageURL];
        }else{
            imageURL = nil;
        }
    }if(imageURL){
        UIImage* profPic = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(profPic){
            return [[UIImageView alloc] initWithImage:profPic];
        }
        else{
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[[PAAssetManager sharedManager] profilePlaceholder]];
            return imageView;
        }
    }
    else{
        return [[UIImageView alloc] initWithImage:[[PAAssetManager sharedManager] profilePlaceholder]];
    }
}

#pragma mark - Utils


-(NSString*)dateToString:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSString * timeOfDay = @" AM";
    if(hour>12){
        hour-=12;
        timeOfDay = @" PM";
    }
    
    NSString *minute = [@([components minute]) stringValue];
    if(minute.length==1){
        minute = [@"0" stringByAppendingString:minute];
    }
    
    NSString * dateString = [[@(hour) stringValue] stringByAppendingString:@":"];
    dateString = [dateString stringByAppendingString:minute];
    dateString = [dateString stringByAppendingString:timeOfDay];
    return dateString;
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
/*
 //DO NOT DELETE (for now)
 #pragma mark - managing the keyboard notifications
 
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
 
 - (void)keyboardWasShown:(NSNotification *)notification {
 if(CGRectEqualToRect(self.tableView.frame, initialFrame)){
 NSDictionary* info = [notification userInfo];
 CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
 [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
 }
 }
 
 - (void)keyboardWillBeHidden:(NSNotification *)notification {
 self.tableView.frame = initialFrame;
 }
 */

@end
