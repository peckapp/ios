//
//  PAPrimaryViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPrimaryViewController.h"
#import "PAAppDelegate.h"
#import "PASessionManager.h"
#import "Event.h"

#import "AFNetworking.h"

@interface PAPrimaryViewController ()

-(void)setAttributesInEvent:(Event*)event withDictionary:(NSDictionary*)dictionary;

@end

@implementation PAPrimaryViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    
    [[PASessionManager sharedClient] GET:@"api/events" parameters:nil success:^
        (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"JSON: %@",JSON);
         NSArray *postsFromResponse = (NSArray*)JSON;
         NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
         for (NSDictionary *eventAttributes in postsFromResponse) {
             NSString *newID = [[eventAttributes objectForKey:@"id"] stringValue];
             BOOL eventAlreadyExists = [self eventExists:newID];
            if(!eventAlreadyExists){
                NSLog(@"about to add the event");
                Event * event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
                [self setAttributesInEvent:event withDictionary:eventAttributes];
                [mutableEvents addObject:event];
                NSLog(@"EVENT: %@",event);
             }
         }
            
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
            NSLog(@"ERROR: %@",error);
    }];
    
    [[PASessionManager sharedClient] POST:@"api/events"
                               parameters:@{}
                                  success:^(NSURLSessionDataTask *task,id responseObject) {
                                      NSLog(@"POST success: %@",responseObject);
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError * error) {
                                      NSLog(@"POST error: %@",error);
                                  }];
}


-(BOOL)eventExists:(NSString *) newID{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *events = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    [request setEntity:events];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", newID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    //fetch events in order to check if the events we want to add already exist in core data
    
    if([mutableFetchResults count]==0)
        return NO;
    else {
        return YES;
    }
}


-(void)setAttributesInEvent:(Event *)event withDictionary:(NSDictionary *)dictionary
{
    NSLog(@"set attributes of event");
    event.title = [dictionary objectForKey:@"title"];
    event.descrip = [dictionary objectForKey:@"description"];
    event.location = [dictionary objectForKey:@"institution"];
    NSString *tempString = [[dictionary objectForKey:@"id"] stringValue];
    event.id = tempString;
    //event.isPublic = [[dictionary objectForKey:@"public"] boolValue];
    //NSDateFormatter * df = [[NSDateFormatter alloc] init];
    //event.startDate = [df dateFromString:[attributes valueForKey:@"start_date"]];
    //event.endDate = [df dateFromString:[attributes valueForKey:@"end_date"]];
    
    // the below doesn't work due to current disparity between the json and coredata terminology
    /*
    NSDictionary *attributes = [[event entity] attributesByName];
    for (NSString *attribute in attributes) {
        id value = [dictionary objectForKey:attribute];
        if (value == nil) {
            continue;
        }
        [event setValue:value forKey:attribute];
    }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
