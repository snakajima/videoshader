//
//  OVLFork.m
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLFork.h"

@implementation OVLFork

-(void) process:(id <OVLNodeDelegate>)delegate {
    GLuint i0 = [delegate popTexture];
    [delegate pushTexture:i0];
    [delegate pushTexture:i0];
}

-(NSString*) nodeKey {
    return @"fork";
}

-(BOOL) emulate:(NSMutableArray*)stack {
    if (stack.count < 1) {
        return NO;
    }
    [stack removeLastObject];
    [stack addObject:@"I"];
    [stack addObject:@"Y"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"control": @"fork" };
}

@end
