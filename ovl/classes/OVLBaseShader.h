//
//  OVLBaseShader.h
//  cartoon
//
//  Created by satoshi on 11/22/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>

@interface OVLBaseShader : NSObject {
    GLuint _programHandle;
}
+(GLuint) compileAndLinkShader:(NSString*)nameVertex fragment:(NSString*)nameFragment;
+(GLuint) compileShader:(NSString*)shaderName withType:(GLenum)shaderType;
+(GLuint) compileShaderString:(NSString*)shaderString withType:(GLenum)shaderType withName:(NSString*)shaderName;
+(GLuint) linkVertex:(GLuint)vs withFragment:(GLuint)fs;
-(id) initWithVertex:(NSString*)nameVertex fragment:(NSString*)nameFragment;
-(id) initWithSize:(CGSize)size;

@end
