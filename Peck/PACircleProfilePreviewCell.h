//
//  PACircleProfilePreviewCell.h
//  Peck
//
//  Created by Jonas Luebbers on 7/25/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAProfileThumbnailView.h"

@interface PACircleProfilePreviewCell : UITableViewCell

@property (strong, nonatomic) PAProfileThumbnailView * profileThumbnail;
@property (weak, nonatomic) IBOutlet UIView *profileTemplateSubview;

@end
