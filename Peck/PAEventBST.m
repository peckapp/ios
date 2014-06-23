//
//  PAEventBST.m
//  Peck
//
//  Created by John Karabinos on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEventBST.h"

@implementation PAEventBST

-(void)addNode:(PAEventBST*) root WithName:(NSString *)newName WithEvent:(Event *) newEvent{
    if(_name==nil){
        _event=newEvent;
        _name=newName;
        
    }
    else{
        NSComparisonResult result = [_name compare:newName];
        if(result==NSOrderedAscending){
            if(!_right){
                _right = [[PAEventBST alloc] init];
            }
            [_right addNode:root WithName:newName WithEvent:newEvent];
        }
        else{
            if(!_left){
                _left = [[PAEventBST alloc] init];
            }
            [_left addNode:root WithName:newName WithEvent:newEvent];
        }
    }
}

-(BOOL)search:(NSString *)searchName{
    NSComparisonResult result = [_name compare: searchName];
    if(result==NSOrderedSame)
        return YES;
    else if(result == NSOrderedAscending){
        if(_right){
            return [_right search: searchName];
        }
    }
    else if(result == NSOrderedDescending){
        if(_left){
            return [_left search: searchName];
        }
    }
    return NO;
}

-(NSMutableArray*)searchForName:(NSString *)searchName WithArray:(NSMutableArray*)currentNames{
    if(self==nil)
        return 0;
    else if([searchName length] <= [_name length]){
        NSString *temp = [_name substringToIndex:[searchName length]];
        if([temp isEqualToString:searchName]){
            [currentNames addObject:_event];
            [currentNames arrayByAddingObjectsFromArray:[_right searchForName:searchName WithArray:currentNames]];
            [currentNames arrayByAddingObjectsFromArray:[_left searchForName:searchName WithArray:currentNames]];
            return currentNames;
        }else{
            [currentNames arrayByAddingObjectsFromArray:[_right searchForName:searchName WithArray:currentNames]];
            [currentNames arrayByAddingObjectsFromArray:[_left searchForName:searchName WithArray:currentNames]];
            return  currentNames;
        }
    }
    else{
        [currentNames arrayByAddingObjectsFromArray:[_right searchForName:searchName WithArray:currentNames]];
        [currentNames arrayByAddingObjectsFromArray:[_left searchForName:searchName WithArray:currentNames]];
        return  currentNames;
        
    }
}



@end

