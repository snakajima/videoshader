//
//  OVLMixer.m
//  cartoon
//
//  Created by satoshi on 11/2/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLMixer.h"

@interface OVLMixer() {
    GLuint _uTexture2;
    GLuint _uTexture3;
}
@end

@implementation OVLMixer

-(void) compile {
    [super compile];
    _uTexture2 = glGetUniformLocation(_ph, "uTexture2");
    _uTexture3 = glGetUniformLocation(_ph, "uTexture3");
}

-(void) process:(id <OVLNodeDelegate>)delegate {
    [delegate prepareFrame]; // we must call it before pop any
    if (![delegate hasDepth:3]) {
        NSLog(@"OVLMixer stack underflow");
        return;
    }

    glUseProgram(_ph);
    glUniform1i(_uTexture3, [delegate popTexture]);
    glUniform1i(_uTexture2, [delegate popTexture]);
    glUniform1i(_uTexture, self.fork ? [delegate forkTexture] : [delegate popTexture]);

    [delegate renderRect];
}

-(BOOL) emulate:(NSMutableArray*)stack {
    if (stack.count < 3) {
        return NO;
    }
    [stack removeLastObject];
    [stack removeLastObject];
    [stack removeLastObject];
    [stack addObject:@"M"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"mixer": _fsh, @"attr": _attrs, @"ui": _ui };
}



@end
