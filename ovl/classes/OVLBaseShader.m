//
//  OVLBaseShader.m
//  cartoon
//
//  Created by satoshi on 11/22/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLBaseShader.h"

@implementation OVLBaseShader

// To be implemented by a subclass
-(id) initWithSize:(CGSize)size {
    return nil;
}

// To be called from subclass's initWithSide: method
-(id) initWithVertex:(NSString*)nameVertex fragment:(NSString*)nameFragment {
    if (self = [super init]) {
        _programHandle = [OVLBaseShader compileAndLinkShader:nameVertex fragment:nameFragment];
    }
    return self;
}

+(GLuint) linkVertex:(GLuint)vs withFragment:(GLuint)fs {
    GLuint handle = glCreateProgram();
    glAttachShader(handle, vs);
    glAttachShader(handle, fs);
    glLinkProgram(handle);
    glDeleteShader(vs);
    glDeleteShader(fs);

    GLint linkSuccess;
    glGetProgramiv(handle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
      GLchar messages[256];
      glGetProgramInfoLog(handle, sizeof(messages), 0, &messages[0]);
      NSString *messageString = [NSString stringWithUTF8String:messages];
      NSLog(@"OGBS link error:%@", messageString);
      exit(1);
    }
    return handle;
}

// A subclass may call this method to create additional programs.
+(GLuint) compileAndLinkShader:(NSString*)nameVertex fragment:(NSString*)nameFragment {
    GLuint vs = [OVLBaseShader compileShader:nameVertex withType:GL_VERTEX_SHADER];
    GLuint fs = [OVLBaseShader compileShader:nameFragment withType:GL_FRAGMENT_SHADER];
    if (!vs || !fs) {
        return 0;
    }
    return [OVLBaseShader linkVertex:vs withFragment:fs];
}

+(GLuint) compileShaderString:(NSString*)shaderString withType:(GLenum)shaderType withName:(NSString*)shaderName {
    GLuint shaderHandle = glCreateShader(shaderType);
 
    const char * shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, NULL);
    glCompileShader(shaderHandle);
 
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"OBS compile error %@:%@", shaderName, messageString);
        return 0;
    }
 
    return shaderHandle;
}

// A helper method to compile a shader
+(GLuint) compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
        encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"OGBS compile error: %@ %@", shaderName, error.localizedDescription);
        return 0;
    }
    return [OVLBaseShader compileShaderString:shaderString withType:shaderType withName:shaderName];
}

-(void) dealloc {
    glDeleteProgram(_programHandle);
}

@end
