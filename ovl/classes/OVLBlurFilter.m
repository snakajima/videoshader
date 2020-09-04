//
//  OVLBlurFilter.m
//  cartoon
//
//  Created by satoshi on 11/11/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLBlurFilter.h"
#import "OVLBaseShader.h"

@interface OVLBlurFilter() {
    GLuint _uPixel;
    GLfloat _pixel[2];
    GLfloat _zoom; // >1.0 if radius>7.0
}
@end

@implementation OVLBlurFilter

-(void) compile {
    [super compile];
    _uPixel = glGetUniformLocation(_ph, "uPixel2");
}

-(void) setPixelSize:(const GLfloat*)pv delegate:(id <OVLNodeDelegate>)delegate {
    _pixel[0] = pv[0];
    _pixel[1] = pv[1];
    //glUniform2fv(_uPixel, 1, _pixel);
}

-(void) deferredSetAttr:(id)value forName:(NSString*)name {
    if (![name isEqualToString:@"radius"]) {
        [super deferredSetAttr:value forName:name];
    }
}

-(void) setAttr:(id)value forName:(NSString*)name {
    if (_fCompiled && [name isEqualToString:@"radius"]) {
        [_attrs setValue:value forKey:name];
        [self compile];
    } else {
        [super setAttr:value forName:name];
    }
}

-(void) process:(id <OVLNodeDelegate>)delegate {
    GLfloat pixelX[2] = { _pixel[0] * _zoom, 0.0 };

    [delegate prepareFrame]; // we must call it before pop any
    if (![delegate hasDepth:1]) {
        NSLog(@"OVLBlurFilter stack underflow");
        return;
    }
    glUseProgram(_ph);
    glUniform1i(_uTexture, self.fork ? [delegate forkTexture] : [delegate popTexture]);
    glUniform2fv(_uPixel, 1, pixelX);
    [self processOrientation];
    [delegate renderRect];

    GLfloat pixelY[2] = { 0.0, _pixel[1] * _zoom };

    [delegate prepareFrame]; // we must call it before pop any
    if (![delegate hasDepth:1]) {
        NSLog(@"OVLBlurFilter stack underflow");
        return;
    }
    //glUseProgram(_ph);
    glUniform1i(_uTexture, self.fork ? [delegate forkTexture] : [delegate popTexture]);
    glUniform2fv(_uPixel, 1, pixelY);
    [self processOrientation];
    [delegate renderRect];
}


-(NSString*) _shaderString:(NSString*)shaderName {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
        encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"OBF compile error: %@ %@", shaderName, error.localizedDescription);
        return nil;
    }
    return shaderString;
}

-(NSString*) _gen:(NSString*)format radius:(NSUInteger)radius weights:(CGFloat*)weights {
    NSMutableArray* items = [NSMutableArray array];
    for (int i=1; i<=radius; i++) {
        NSString* item = [NSString stringWithFormat:format, i, weights[i]];
        [items addObject:item];
    }
    return [items componentsJoinedByString:@"\n"];
}

#define V1_STR @"varying vec2 vTextCoordP%1$d;varying vec2 vTextCoordN%1$d;"
#define V2_STR @"\tvTextCoordP%1$d = aTextCoord + uPixel2 * %1$d.0;vTextCoordN%1$d = aTextCoord - uPixel2 * %1$d.0;"

#define F1_STR @"varying mediump vec2 vTextCoordP%1$d;varying mediump vec2 vTextCoordN%1$d;"
#define F2_STR @"mediump vec4 color = texture2D(uTexture, vTextCoord);"
#define F3_STR @"\tcolor += texture2D(uTexture, vTextCoordP%1$d);color += texture2D(uTexture, vTextCoordN%1$d);"
#define F4_STR @"\tgl_FragColor = color / %1$d.0;"

#define F2_STRF @"mediump vec4 color = texture2D(uTexture, vTextCoord) * %2$f;"
#define F3_STRF @"\tcolor += texture2D(uTexture, vTextCoordP%1$d) * %2$f;color += texture2D(uTexture, vTextCoordN%1$d) * %2$f;"
#define F4_STRF @"\tgl_FragColor = color;"

#define F2_STRT @"mediump vec4 color = texture2D(uTexture, vTextCoord) * w[%1$d];"
#define F3_STRT @"\tcolor += texture2D(uTexture, vTextCoordP%1$d) * w[%1$d];color += texture2D(uTexture, vTextCoordN%1$d) * w[%1$d];"
#define F4_STRT @"\tgl_FragColor = color / wt;"

#define F3_STRB @"\tcolor = max(color, texture2D(uTexture, vTextCoordP%1$d));  color = max(color, texture2D(uTexture, vTextCoordN%1$d));"

-(void) innerCompile {
    //NSLog(@"OBF innerCompile");
    
    NSString* vertexFile = [NSString stringWithFormat:@"%@.vsh", _vsh];
    NSString* fragmentFile = [NSString stringWithFormat:@"%@.fsh", _fsh];
    
    NSString* vString = [self _shaderString:vertexFile];
    NSString* fString = [self _shaderString:fragmentFile];

    NSNumber* num = _attrs[@"radius"];
    CGFloat radius = num.floatValue;
    int iRadius = floor(radius);
    if (num.floatValue > 7) {
        _zoom = num.floatValue / 7.0;
        iRadius = 7;
    } else {
        _zoom = 1.0;
    }
    
    NSString* s_fmts[4][4] = {
        { F1_STR, F2_STR, F3_STR, F4_STR },
        { F1_STR, F2_STRF, F3_STRF, F4_STRF },
        { F1_STR, F2_STRT, F3_STRT, F4_STRT },
        { F1_STR, F2_STR, F3_STRB, F4_STRF }
    };
    NSUInteger iFmt = 0;
    
    CGFloat weights[8] = { 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 };
    if ([_fsh isEqualToString:@"gaussianblur"]) {
        //NSLog(@"OVLBF ### gaussian %f", radius);
        CGFloat sigma = iRadius/2.0;
        CGFloat total = 0.0;
        for (int i=0; i<=iRadius; i++) {
            CGFloat w = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0))) * exp(-pow(i, 2.0) / (2.0 * pow(sigma, 2.0)));
            weights[i] = w;
            total += (i==0) ? w : (w+w);
        }
        for (int i=0; i<=iRadius; i++) {
            weights[i] /= total;
            //NSLog(@"OVLBF %d, %f", i, weights[i]);
        }
        iFmt = 1;
    } else if ([_fsh isEqualToString:@"tilt_shift"]) {
        iFmt = 2;
    } else if ([_fsh isEqualToString:@"embold"]) {
        iFmt = 3;
    }
    NSString* v1 = [self _gen:V1_STR radius:iRadius weights:weights];
    NSString* v2 = [self _gen:V2_STR radius:iRadius weights:weights];
    //NSLog(@"v1=\n%@\n\n%@", v1, v2);
    vString = [NSString stringWithFormat:vString, v1, v2];
    
    //NSLog(@"%@", vString);
    NSString* f1 = [self _gen:s_fmts[iFmt][0] radius:iRadius weights:weights];
    NSString* f2 = [NSString stringWithFormat:s_fmts[iFmt][1], weights[0]];
    NSString* f3 = [self _gen:s_fmts[iFmt][2] radius:iRadius weights:weights];
    NSString* f4 = [NSString stringWithFormat:s_fmts[iFmt][3], iRadius*2+1];
    //NSLog(@"11=\n%@\n\n%@\n%@", f1, f2, f3);
    fString = [NSString stringWithFormat:fString, f1, f2, f3, f4];
    //NSLog(@"%@", fString);
    
    GLuint vs = [OVLBaseShader compileShaderString:vString withType:GL_VERTEX_SHADER withName:vertexFile];
    GLuint fs = [OVLBaseShader compileShaderString:fString withType:GL_FRAGMENT_SHADER withName:fragmentFile];

    _ph = [OVLBaseShader linkVertex:vs withFragment:fs];
}

@end
