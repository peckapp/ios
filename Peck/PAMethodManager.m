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
#import <FacebookSDK/FacebookSDK.h>

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

-(void)postInfoToFacebook:(NSDictionary*)eventInfo withImage:(NSData*)imageData{
    //NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:[eventInfo objectForKey:@"image"]]];
    //UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    UIImage* img = [UIImage imageWithData:imageData];
    if(img){
        [FBRequestConnection startForUploadStagingResourceWithImage:img completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error) {
                // Log the uri of the staged image
                NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
                
                // Further code to post the OG story goes here
                
                
                // instantiate a Facebook Open Graph object
                NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
                
                // specify that this Open Graph object will be posted to Facebook
                object.provisionedForPost = YES;
                
                // for og:title
                object[@"title"] = [eventInfo objectForKey:@"title"]; ;
                
                // for og:type, this corresponds to the Namespace you've set for your app and the object type name
                object[@"type"] = @"com_peckapp_peck:event";
                
                // for og:description
                object[@"description"] =[eventInfo objectForKey:@"event_description"] ;
                
                // for og:url, we cover how this is used in the "Deep Linking" section below
                object[@"url"] = @"http://loki.peckapp.com:3500/deep_links/native_peck";
                
                //object[@"url"] = @"http://example.com/roasted_pumpkin_seeds";
                //TODO: fix the url to work with deep linking
                
                // for og:image we assign the image that we just staged, using the uri we got as a response
                // the image has to be packed in a dictionary like this:
                object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
                
                //object[@"event_id"] = [[eventInfo objectForKey:@"id"] stringValue];
                
                /*
                 [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 if(!error) {
                 // get the object ID for the Open Graph object that is now stored in the Object API
                 NSString *objectId = [result objectForKey:@"id"];
                 NSLog(@"object id: %@", objectId);
                 
                 // Further code to post the OG story goes here
                 
                 } else {
                 // An error occurred
                 NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
                 }
                 }];*/
                
                
                
                // Create an action
                id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                
                // Link the object to the action
                [action setObject:object forKey:@"event"];
                
                // Check if the Facebook app is installed and we can present the share dialog
                FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
                params.action = action;
                params.actionType = @"com_peckapp_peck:event";
                
                // If the Facebook app is installed and we can present the share dialog
                if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
                    // Show the share dialog
                    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                                          actionType:@"com_peckapp_peck:post"
                                                 previewPropertyName:@"event"
                                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                 if(error) {
                                                                     // There was an error
                                                                     NSLog(@"Error publishing story: %@", error.description);
                                                                 } else {
                                                                     // Success
                                                                     NSLog(@"result %@", results);
                                                                 }
                                                             }];
                    
                    // If the Facebook app is NOT installed and we can't present the share dialog
                } else {
                    // FALLBACK GOES HERE
                }
                
                
            } else {
                // An error occurred
                NSLog(@"Error staging an image: %@", error);
            }
        }];
        
    }
    
    
}


@end
