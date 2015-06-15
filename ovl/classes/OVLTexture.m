//
//  OVLTexture.m
//  cartoon
//
//  Created by satoshi on 2/22/14.
//  Copyright (c) 2014 satoshi. All rights reserved.
//

#import "OVLTexture.h"
#import "OVLPlaneShaders.h"

@interface OVLTexture() {
    GLKTextureInfo* _texture;
    GLuint _uTexture2;
}
@end
@implementation OVLTexture

-(void) compile {
    [super compile];
    _uTexture2 = glGetUniformLocation(_ph, "uTexture");
}

-(void) process:(id <OVLNodeDelegate>)delegate {
    [delegate prepareFrame]; // we must call it before pop any
    glUseProgram(_ph);
    if (_uTime >= 0) {
        glUniform1f(_uTime, [delegate currentTime]); // safe
    }
    glActiveTexture(GL_TEXTURE0 + TEXTURE_INDEX_TEXTURE);
    glBindTexture(GL_TEXTURE_2D, _texture.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(_uTexture2, TEXTURE_INDEX_TEXTURE);
    [delegate renderRect];
}

-(void) deferredSetAttr:(id)value forName:(NSString *)name {
    if ([name isEqualToString:@"texture"]) {
        glUseProgram(_ph);
        //value = @"icon_vinfo";
        NSError* err = nil;
        if (self.imageTexture) {
            _texture = [GLKTextureLoader textureWithCGImage:self.imageTexture.CGImage options:nil error:&err];
        } else {
            NSString *path = [[NSBundle mainBundle] pathForResource:value ofType:@"png"];
            _texture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&err];
        }
        if (err) {
            NSLog(@"OVLT setAttr err=%@", err);
        }
    } else {
        [super deferredSetAttr:value forName:name];
    }
}

@end
