//
//  OVLTexturedFilter.m
//  cartoon
//
//  Created by satoshi on 2/22/14.
//  Copyright (c) 2014 satoshi. All rights reserved.
//

#import "OVLTexturedFilter.h"
#import "OVLPlaneShaders.h"

@interface OVLTexturedFilter() {
    GLKTextureInfo* _texture;
    GLuint _uTexture2;
    GLuint _uPixel;
    GLfloat _pixel[2];
    GLuint _uOffset;
}
@end

@implementation OVLTexturedFilter

-(void) compile {
    [super compile];
    _uTexture2 = glGetUniformLocation(_ph, "uTexture2");
    _uPixel = glGetUniformLocation(_ph, "uAspect");
    if (self.fOrientation) {
        _uOffset = glGetUniformLocation(_ph, "uOffset");
    }
}

-(void) setPixelSize:(const GLfloat*)pv delegate:(id <OVLNodeDelegate>)delegate {
    _pixel[0] = pv[1]/pv[0];
    _pixel[1] = 1.0;
}

-(void) innerProcess:(UIDeviceOrientation)orientation {
    glActiveTexture(GL_TEXTURE0 + TEXTURE_INDEX_TEXTURE);
    glBindTexture(GL_TEXTURE_2D, _texture.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    // clipping will be done by the vertex shader
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glUniform1i(_uTexture2, TEXTURE_INDEX_TEXTURE);
    glUniform2fv(_uPixel, 1, _pixel);
    if (self.fOrientation) {
        switch (orientation) {
        case UIDeviceOrientationPortrait:
            glUniform2f(_uOffset, 1.0, 0.0);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            glUniform2f(_uOffset, 0.0, 1.0);
            break;
        case UIDeviceOrientationLandscapeRight:
            glUniform2f(_uOffset, 0.0, 0.0);
            break;
        default:
            glUniform2f(_uOffset, 1.0, 1.0);
            break;
        }
    }
}

// http://kishimoto.com.br/blog/2013/07/22/bug-na-implementacao-opengl-glkit-framework-da-apple/

-(void) deferredSetAttr:(id)value forName:(NSString *)name {
    if ([name isEqualToString:@"texture"]) {
        if ([value isKindOfClass:[NSString class]]) {
            glUseProgram(_ph);
            GLenum glError = glGetError(); // HACK to work around OpenGL bug (see the link above)
            if (glError) {
                NSLog(@"OVLTF glError = %d", glError);
            }
            NSString *path = [[NSBundle mainBundle] pathForResource:value ofType:@"png"];
            NSError* err = nil;
            _texture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&err];
            if (err) {
                NSLog(@"OVLTF setAttr err=%@", err);
            }
        }
    } else {
        [super deferredSetAttr:value forName:name];
    }
}

@end
