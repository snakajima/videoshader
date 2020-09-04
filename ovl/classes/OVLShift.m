//
//  OVLShift.m
//  cartoon
//
//  Created by satoshi on 10/28/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLShift.h"

@implementation OVLShift

-(void) process:(id <OVLNodeDelegate>)delegate {
    [delegate shiftTexture];
}

-(NSString*) nodeKey {
    return @"shift";
}

-(BOOL) emulate:(NSMutableArray*)stack {
    if (stack.count < 2) {
        return NO;
    }
    [stack removeLastObject];
    [stack removeLastObject];
    [stack addObject:@"I"];
    [stack addObject:@"H"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"control": @"shift" };
}


@end
