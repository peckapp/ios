//
//  PAPostViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)cancelButton:(id)sender;
@property (strong, nonatomic) NSArray *eventItems;
@property (strong, nonatomic) NSArray *eventSuggestions;


@end
