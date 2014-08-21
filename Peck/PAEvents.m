//
//  PAEvents.m
//  Peck
//
//  Created by John Karabinos on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEvents.h"
#import "PAEventBST.h"
#import "PAAppDelegate.h"

@interface PAEvents(){
    
}

@end

@implementation PAEvents{
    
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)events {
    static PAEvents *_events = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _events = [[PAEvents alloc] init];
    });
    
    return _events;
}

-(id)init{
    self = [super init];
    
    if (self) {
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        
        NSFetchRequest * request = [[NSFetchRequest alloc] init];
        NSEntityDescription *events = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
        [request setEntity:events];
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        
        self.eventTree = [[PAEventBST alloc] init];
        
        for(int i=0; i<[mutableFetchResults count]; i++){
            Event *tempEvent = mutableFetchResults[i];
            [self.eventTree addNode:self.eventTree WithName:tempEvent.title WithEvent:tempEvent];
        }
    }
    
    return self;
}


@end
