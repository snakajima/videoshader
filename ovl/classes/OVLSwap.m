//
//  OVLSwap.m
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLSwap.h"

@implementation OVLSwap

-(void) process:(id <OVLNodeDelegate>)delegate {
    GLuint i0 = [delegate popTexture];
    GLuint i1 = [delegate popTexture];
    [delegate pushTexture:i0];
    [delegate pushTexture:i1];
}

-(NSString*) nodeKey {
    return @"swap";
}

-(BOOL) emulate:(NSMutableArray*)stack {
    if (stack.count < 2) {
        return NO;
    }
    [stack removeLastObject];
    [stack removeLastObject];
    [stack addObject:@"I"];
    [stack addObject:@"X"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"control": @"swap" };
}

@end
