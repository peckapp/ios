//
//  PABST.m
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PABST.h"

@implementation PABST


-(void)addNode:(PABST*) root WithName:(NSString *)newName{
    if(_name==nil){
        _name=newName;
    }
    else{
        NSComparisonResult result = [_name compare:newName];
        if(result==NSOrderedAscending){
            if(!_right){
                _right = [[PABST alloc] init];
            }
            [_right addNode:root WithName:newName];
        }
        else{
            if(!_left){
                _left = [[PABST alloc] init];
            }
            [_left addNode:root WithName:newName];
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
   // NSMutableArray *names;
    if(self==nil)
        return 0;
    else if([searchName length] <= [_name length]){
        NSString *temp = [_name substringToIndex:[searchName length]];
        if([temp isEqualToString:searchName]){
            [currentNames addObject:_name];
            [currentNames arrayByAddingObjectsFromArray:[_right searchForName:searchName WithArray:currentNames]];
            [currentNames arrayByAddingObjectsFromArray:[_left searchForName:searchName WithArray:currentNames]];
            return currentNames;
            //return 1 + [_right searchForName:searchName] + [_left searchForName:searchName];
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
