//
//  PAMethodManager.m
//  Peck
//
//  Created by John Karabinos on 8/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAMethodManager.h"
#import "Peer.h"
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"

@implementation PAMethodManager



+ (instancetype)sharedMethodManager{
    
    static PAMethodManager *_sharedMethodManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMethodManager = [[PAMethodManager alloc] init];
    });
    
    return _sharedMethodManager;
}

-(void)showRegisterAlert:(NSString*)message forViewController:(UIViewController *)sender{
    /*Brings up a ui alert if an unregistered user attempts to perform an action reserved for registered users
    ACTIONS SO FAR:
        Posting an event
        Posting an announcement
        Posting a comment to an event (they will not be able to post to a circle because they will not have any)
        Attending an event
        Creating a circle
    */
    
    message =[@"Please login or register to " stringByAppendingString:message];
    self.sender = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unregistered Account"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Register", nil];
    
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"button index: %li", (long)buttonIndex);
    if(buttonIndex==1){
        //The user has selected register
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *registerControllet = [loginStoryboard instantiateViewControllerWithIdentifier:@"register"];
        [self.sender presentViewController:registerControllet animated:YES completion:nil];
    }
}



-(UIImageView*)imageForPeer:(Peer*)peer{
    if (peer.imageURL) {
        NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:peer.imageURL]];
        UIImage* image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(image){
            return [[UIImageView alloc] initWithImage:image];
        }
        else {
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[[PAAssetManager sharedManager] profilePlaceholder]];
            return imageView;
        }
    }
    else {
        return [[UIImageView alloc] initWithImage:[[PAAssetManager sharedManager] profilePlaceholder]];
    }

}

@end
