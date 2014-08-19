//
//  PASendFeedbackViewController.m
//  Peck
//
//  Created by John Karabinos on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASendFeedbackViewController.h"
#import "PASyncManager.h"

@interface PASendFeedbackViewController ()

@end

@implementation PASendFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.feedbackTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)automaticallyAdjustsScrollViewInsets{
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    
}

- (IBAction)sendButton:(id)sender {
    if(![self.feedbackTextView.text isEqualToString:@""]){
        NSLog(@"send the feedback");
        NSString* category = @"problem";
        if(self.categoryControl.selectedSegmentIndex==1){
            category=@"suggestion";
        }
        [[PASyncManager globalSyncManager] sendUserFeedback:self.feedbackTextView.text withCategory:category];
        [self dismissViewControllerAnimated:YES completion:^(void){}];
    }
}
@end
