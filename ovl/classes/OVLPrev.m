//
//  OVLPrev.m
//  cartoon
//
//  Created by satoshi on 3/17/14.
//  Copyright (c) 2014 satoshi. All rights reserved.
//

#import "OVLPrev.h"

@implementation OVLPrev

-(void) process:(id <OVLNodeDelegate>)delegate {
    [delegate inheritTexture];
}

-(NSString*) nodeKey {
    return @"previous";
}

-(BOOL) emulate:(NSMutableArray*)stack {
    [stack addObject:@"S"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"control": @"previous" };
}

@end
