//
//  PAFriendProfileViewController.m
//  Peck
//
//  Created by John Karabinos on 6/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFriendProfileViewController.h"
#import "Peer.h"
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"

@interface PAFriendProfileViewController ()

@end

@implementation PAFriendProfileViewController

@synthesize profilePicture, nameLabel, blurbTextView;
@synthesize fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

PAAssetManager * assetManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)configureView
{
    
    if(self.peer){
    
        self.nameLabel.text = self.peer.name;
        self.blurbTextView.text = self.peer.blurb;
    
        if(self.peer.imageURL){
            NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:self.peer.imageURL]];
            [self.profilePicture setImageWithURL:imageURL placeholderImage:[assetManager profilePlaceholder]];
        }else{
            self.profilePicture.image = [UIImage imageNamed:@"profile-placeholder.png"];
        }
    }else{
        //the user is attempting to view their own profile
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        self.nameLabel.text = [[[defaults objectForKey:@"first_name"] stringByAppendingString:@" "] stringByAppendingString:[defaults objectForKey:@"last_name"]];
        self.blurbTextView.text = [defaults objectForKey:@"blurb"];
        
        NSURL* url = [NSURL URLWithString:[defaults objectForKey:@"profile_picture_url"]];
        if(url){
            [self.profilePicture setImageWithURL:url placeholderImage:[assetManager profilePlaceholder]];
        }else{
            self.profilePicture.image = [UIImage imageNamed:@"profile-placeholder.png"];
        }
        
    }
    
    //For some reason these methods were making the image not show up
    
    //self.profilePicture.layer.cornerRadius = 256;
    //self.profilePicture.clipsToBounds = YES;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    assetManager = [PAAssetManager sharedManager];
    [blurbTextView setEditable:NO];
    /*blurbTextView.layer.borderWidth=.5f;
    blurbTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    blurbTextView.layer.cornerRadius = 8;*/
    
    [self.scrollView setScrollEnabled:YES];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-123);
    //subtracting 123 gives a height that is large enough to provide minimal scrolling
    
    [self configureView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (UIImageView *)imageForPeer:(Peer*)peer
{
    if (peer.imageURL) {
        NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:peer.imageURL]];
        UIImage* image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(image){
            return [[UIImageView alloc] initWithImage:image];
        }
        else {
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[assetManager profilePlaceholder]];
            return imageView;
        }
    }
    else {
        return [[UIImageView alloc] initWithImage:[assetManager profilePlaceholder]];
    }
    
}*/

-(UIImageView*)imageForPeer:(Peer*)peer{
    if (peer.imageURL) {
        NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:peer.imageURL]];
        UIImageView * imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:imageURL placeholderImage:[assetManager profilePlaceholder]];
        return imageView;
    }
    else{
         return [[UIImageView alloc] initWithImage:[assetManager profilePlaceholder]];
    }
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

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}
@end
