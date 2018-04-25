//
//  OVLSource.m
//  cartoon
//
//  Created by satoshi on 11/1/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLSource.h"

@implementation OVLSource

-(void) process:(id <OVLNodeDelegate>)delegate {
    
    [delegate prepareFrame]; // we must call it before pop any
    glUseProgram(_ph);
    if (_uTime >= 0) {
        glUniform1f(_uTime, [delegate currentTime]); // safe
    }
    if (_uAudio >=0) {
        glUniform1f(_uAudio, [delegate audioVolume]); // safe
    }
    [delegate renderRect];
}

-(BOOL) emulate:(NSMutableArray*)stack {
    [stack addObject:@"S"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"source": _fsh, @"attr": _attrs, @"ui": _ui };
}

@end
