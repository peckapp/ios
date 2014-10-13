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

#define separatorWidth 1.0

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

-(void) showSeparators {
    [self.view.layer addSublayer:self.upperSeparator];
    self.upperSeparator.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.origin.y, self.view.layer.frame.size.width, separatorWidth);
    
    [self.view.layer addSublayer:self.lowerSeparator];
    self.lowerSeparator.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.size.height - separatorWidth, self.view.layer.frame.size.width, separatorWidth);
}

-(void) hideSeparators {
    [self.upperSeparator removeFromSuperlayer];
    
    [self.lowerSeparator removeFromSuperlayer];
}

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
    abort();
}

-(void)setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject {
    abort();
}

-(void)compressAnimated:(BOOL)animated {
    abort();
}

-(void)expandAnimated:(BOOL)animated {
    abort();
}

-(UIView*) viewForBackButton {
    return nil;
}

@end
