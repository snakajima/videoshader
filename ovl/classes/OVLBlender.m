//
//  OVLBlender.m
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLBlender.h"

@implementation OVLBlender

-(void) compile {
    [super compile];
    _uTexture2 = glGetUniformLocation(_ph, "uTexture2");
}

-(void) process:(id <OVLNodeDelegate>)delegate {
    [delegate prepareFrame]; // we must call it before pop any
    if (![delegate hasDepth:2]) {
        NSLog(@"OVLBlender stack underflow");
        return;
    }

    glUseProgram(_ph);
    glUniform1i(_uTexture2, [delegate popTexture]);
    glUniform1i(_uTexture, self.fork ? [delegate forkTexture] : [delegate popTexture]);
    if (_uTime >= 0) {
        glUniform1f(_uTime, [delegate currentTime]); // safe
    }
    if (_uAudio >=0) {
        glUniform1f(_uAudio, [delegate audioVolume]); // safe
    }

    [delegate renderRect];
}

-(BOOL) emulate:(NSMutableArray*)stack {
    if (stack.count < 2) {
        return NO;
    }
    [stack removeLastObject];
    [stack removeLastObject];
    [stack addObject:@"B"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"blender": _fsh, @"attr": _attrs, @"ui": _ui };
}


@end
