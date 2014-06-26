//
//  PACircleScrollView.m
//  Peck
//
//  Created by John Karabinos on 6/25/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACircleScrollView.h"

@implementation PACircleScrollView

@synthesize numberOfMembers = _numberOfMembers;
@synthesize memberPhotos = _memberPhotos;
@synthesize nameLabels = _nameLabels;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setScrollEnabled:YES];
        
        UITapGestureRecognizer *tapRecognizer;
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProfile:)];
        tapRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapRecognizer];
        self.userInteractionEnabled =YES;
        _memberPhotos = [[NSMutableArray alloc] init];
        _nameLabels = [[NSMutableArray alloc] init];
        
        return self;
    }
    return self;
}

-(id)init{
    
    [self setScrollEnabled:YES];
    
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProfile:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled =YES;
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)selectProfile: (UIGestureRecognizer*) sender{
    CGPoint tapPoint = [sender locationInView:self];
    int peer = (int) tapPoint.x;
    peer = (peer/80);
    [self.delegate removePeer:peer];
}


-(void)addPeer:(UIImage*)image WithName:(NSString*)name{
    [self setContentSize:CGSizeMake(80*(_numberOfMembers+1), 60)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80*_numberOfMembers, 0, 55, 44)];
    imageView.image=image;
    _memberPhotos[_numberOfMembers] = imageView;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80*_numberOfMembers, 44, 70, 16)];
    nameLabel.text=name;
    _nameLabels[_numberOfMembers] = nameLabel;
    [self addSubview:imageView];
    [self addSubview:nameLabel];
     _numberOfMembers++;
}

-(void)removePeer:(int)peer{
    int i;
    for(i=peer; i<(_numberOfMembers-1); i++){
        UIImageView *imageView1 = _memberPhotos[i];
        UIImageView *imageView2 = _memberPhotos[i+1];
        UIImage *image= imageView2.image;
        imageView1.image=image;
        
        UILabel * nameLabel1 = (UILabel *) _nameLabels[i];
        UILabel * nameLabel2 = (UILabel *) _nameLabels[i+1];
        nameLabel1.text = nameLabel2.text;
    }
    UIImageView *finalImageView = _memberPhotos[i];
    [finalImageView removeFromSuperview];
    UILabel *finalLabel = _nameLabels[i];
    [finalLabel removeFromSuperview];
    [_memberPhotos removeObjectAtIndex:i];
    [_nameLabels removeObjectAtIndex:i];
    _numberOfMembers--;
}

@end
