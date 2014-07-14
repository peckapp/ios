//
//  PADiningCell.m
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADiningCell.h"

@implementation PADiningCell

@synthesize nameLabel, startLabel, endLabel;
@synthesize menuItemsTableView;
- (void)awakeFromNib
{
    self.menuItemsTableView.delegate=self;
    self.menuItemsTableView.dataSource=self;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuItem"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuItem"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.text=@"FOOOOOD";
}


@end
