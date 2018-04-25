//
//  OVLFilter.m
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLFilter.h"
#import "OVLBaseShader.h"
#import "OVLShaderManager.h"

@interface OVLFilter()
@end

@implementation OVLFilter

static BOOL s_fFrontCameraMode = NO;

+(void) setFrontCameraMode:(BOOL)flag {
    s_fFrontCameraMode = flag;
}

+(BOOL) isFrontCameraMode {
    return s_fFrontCameraMode;
}

-(id) initWithVertexShader:(NSString*)vsh fragmentShader:(NSString*)fsh {
    if (self = [super init]) {
        _fsh = fsh;
        _vsh = vsh;
        _attrs = [NSMutableDictionary dictionary];
        _ui = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSString*) shader {
    return _fsh;
}

-(void) innerCompile {
    NSString* vertexFile = [NSString stringWithFormat:@"%@.vsh", _vsh];
    NSString* filterFile = [NSString stringWithFormat:@"%@.fsh", _fsh];
    _ph = [OVLBaseShader compileAndLinkShader:vertexFile fragment:filterFile];
}

-(void) compile {
    if (_fCompiled) {
        glDeleteProgram(_ph);
    }

    [self innerCompile];

    glUseProgram(_ph);
    GLKMatrix4 matrix = GLKMatrix4MakeOrtho(0.0, 1.0, 0.0, 1.0, 1.0, 100.0);
    GLKMatrix4 modelView = GLKMatrix4Identity;
    glUniformMatrix4fv(glGetUniformLocation(_ph, "uProjection"), 1, 0, matrix.m);
    glUniformMatrix4fv(glGetUniformLocation(_ph, "uModelView"), 1, 0, modelView.m);
    _uTexture = glGetUniformLocation(_ph, "uTexture");
    _uTime = glGetUniformLocation(_ph, "uTime");
    _fCompiled = YES;
    if (self.fOrientation) {
        _uOrientation = glGetUniformLocation(_ph, "uOrientation");
    }
    if (self.fAudio) {
        _uAudio = glGetUniformLocation(_ph, "uAudio"); // safe
    } else {
        _uAudio = -1;
    }
    
    for (NSString* key in _attrs.allKeys) {
        [self deferredSetAttr:_attrs[key] forName:key];
    }
}

-(void) clearProgram {
    if (_ph) {
        glDeleteProgram(_ph);
        _ph = 0;
    }
    _fCompiled = NO;
}

-(void) set2fv:(const GLfloat*)pv forName:(const GLchar*)name {
    glUseProgram(_ph);
    GLint loc = glGetUniformLocation(_ph, name);
    //NSLog(@"### loc=%d", loc);
    if (loc >= 0) {
        glUniform2fv(loc, 1, pv);
    }
}

-(void) setAttr:(id)value forName:(NSString*)name {
    [_attrs setValue:value forKey:name]; // only for stringFromAttrs
    if (_fCompiled) {
        [self deferredSetAttr:value forName:name];
    }
}

-(void) setUI:(NSDictionary*)ui {
    _ui = ui ? [NSMutableDictionary dictionaryWithDictionary:ui]
             : [NSMutableDictionary dictionary];
}

-(void) setExtra:(NSDictionary*)extra {
    _extra = extra;
    // BUGBUG: Wrong location
    if (self.fOrientation) {
        UIDevice* device = [UIDevice currentDevice];
        _orientation = device.orientation;
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:device];
    }
}

-(void) deviceOrientationDidChange:(NSNotification*)n {
    UIDevice* device = [UIDevice currentDevice];
    switch (device.orientation) {
      case UIDeviceOrientationFaceDown:
      case UIDeviceOrientationFaceUp:
        // ignore this change for "sticky orientation"
        break;

      default:
        _orientation = device.orientation;
        break;
    }
    //NSLog(@"OVLT orientation change %ld", _orientation);
}

-(BOOL) hasPrimary {
    NSArray* keys = _ui[@"primary"];
    return (keys.count > 0);
}

-(NSArray*) primaryAttributeKeys {
    return _ui[@"primary"];
}

-(BOOL) isPrimeryKey:(NSString*)key {
//    NSSet* set = [NSSet setWithArray:self.primaryAttributeKeys];
//    return [set containsObject:key];
    return [self.primaryAttributeKeys containsObject:key];
}

-(void) addPrimaryKey:(NSString*)key {
    NSMutableSet* set = [NSMutableSet setWithArray:self.primaryAttributeKeys];
    [set addObject:key];
    _ui[@"primary"] = [set allObjects];
}

-(void) removePrimaryKey:(NSString*)key {
    NSMutableSet* set = [NSMutableSet setWithArray:self.primaryAttributeKeys];
    [set removeObject:key];
    _ui[@"primary"] = [set allObjects];
}

-(void) removeAllPrimaryKeys {
    _ui[@"primary"] = @[];
}

-(void) setDefault {
    OVLShaderManager* manager = [OVLShaderManager sharedInstance];
    NSDictionary* infos = [manager attrOfShader:_fsh];
    for (NSString* key in infos.allKeys) {
        NSDictionary* info = infos[key];
        [self setAttr:info[@"default"] forName:key];
    }
}

-(id) attrForName:(NSString*)name {
    return [_attrs valueForKey:name];
}

-(void) deferredSetAttr:(id)value forName:(NSString*)name {
    glUseProgram(_ph);
    GLint glid = glGetUniformLocation(_ph, name.UTF8String);
    if (glid < 0) {
        NSLog(@"OVLF #### glid<0 %@, %@, %@", name, _vsh, _fsh);
        return;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray* array = value;
        if (array.count == 3) {
            NSNumber* r = array[0];
            NSNumber* g = array[1];
            NSNumber* b = array[2];
            glUniform3f(glid, r.floatValue, g.floatValue, b.floatValue);
        } else if (array.count == 4) {
            NSNumber* r = array[0];
            NSNumber* g = array[1];
            NSNumber* b = array[2];
            NSNumber* a = array[3];
            glUniform4f(glid, r.floatValue, g.floatValue, b.floatValue, a.floatValue);
        } else if (array.count == 2) {
            NSNumber* x = array[0];
            NSNumber* y = array[1];
            glUniform2f(glid, x.floatValue, y.floatValue);
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber* num = value;
        glUniform1f(glid, num.floatValue);
    }
}

-(NSString*) _float2str:(NSNumber*)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    return [formatter stringFromNumber:value];
}

-(NSSet*) hiddenKeys {
    NSArray* hidden = _ui[@"hidden"];
    return hidden ? [NSSet setWithArray:hidden] : nil;
}

-(NSString*) stringFromAttrs {
    NSMutableArray* items = [NSMutableArray array];
    NSSet* set = [self hiddenKeys];
    for (NSString* key in _attrs.allKeys) {
        if (![set containsObject:key]) {
            id value = _attrs[key];
            if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray* array = [NSMutableArray array];
                for (NSNumber* num in (NSArray*)value) {
                    [array addObject:[self _float2str:num]];
                }
                value = [array componentsJoinedByString:@","];
                value = [NSString stringWithFormat:@"[%@]", value];
            } else {
                value = [self _float2str:value];
            }
            [items addObject:[NSString stringWithFormat:@"%@:%@", key, value]];
        }
    }
    return [items componentsJoinedByString:@", "];
}

-(void) innerProcess:(UIDeviceOrientation)orientation {
    // to be implemented in the subclasses
}

-(void) setOrientation:(UIDeviceOrientation)orientation {
    if (self.fOrientation) {
        _orientation = orientation;
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

-(void) processOrientation {
    UIDeviceOrientation orientation = _orientation;
    if (self.fOrientation) {
        if ([OVLFilter isFrontCameraMode]) {
            if (orientation == UIDeviceOrientationLandscapeLeft) {
                orientation = UIDeviceOrientationLandscapeRight;
            } else if (orientation == UIDeviceOrientationLandscapeRight) {
                orientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        static GLfloat s_matrixLL[] = {1.0, 0.0, 0.0, 1.0};
        static GLfloat s_matrixLR[] = {-1.0, 0.0, 0.0, -1.0};
        static GLfloat s_matrixPU[] = {0.0, 1.0, -1.0, 0.0};
        static GLfloat s_matrixP[] = {0.0, -1.0, 1.0, 0.0};
        switch (orientation) {
        case UIDeviceOrientationPortrait:
            glUniformMatrix2fv(_uOrientation, 1, 0, s_matrixP);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            glUniformMatrix2fv(_uOrientation, 1, 0, s_matrixPU);
            break;
        case UIDeviceOrientationLandscapeRight:
            glUniformMatrix2fv(_uOrientation, 1, 0, s_matrixLR);
            break;
        default:
            glUniformMatrix2fv(_uOrientation, 1, 0, s_matrixLL);
            break;
        }
    }
    [self innerProcess:orientation];
}

-(void) process:(id <OVLNodeDelegate>)delegate {
    NSInteger count = self.repeat;
    do {
        [delegate prepareFrame]; // we must call it before pop any
        if (![delegate hasDepth:1]) {
            NSLog(@"OVLFilter stack underflow");
            return;
        }

        glUseProgram(_ph);
        glUniform1i(_uTexture, self.fork ? [delegate forkTexture] : [delegate popTexture]);
        if (_uTime >= 0) {
            glUniform1f(_uTime, [delegate currentTime]); // safe
        }
        [self processOrientation];

        [delegate renderRect];
    } while (--count > 0);
}

-(NSString*) nodeKey {
    return _fsh;
}

-(BOOL) emulate:(NSMutableArray*)stack {
    if (stack.count < 1) {
        return NO;
    }
    [stack removeLastObject];
    [stack addObject:@"F"];
    return YES;
}

-(NSDictionary*) jsonObject {
    return @{ @"filter": _fsh, @"attr": _attrs, @"ui": _ui };
}

-(NSDictionary*) attributes {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_attrs];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

-(void) setAttributes:(NSDictionary*)attributes {
    for (NSString* key in attributes.allKeys) {
        [_attrs setValue:attributes[key] forKey:key];
    }
}


-(void) dealloc {
    if (_ph) {
        glDeleteProgram(_ph);
        /*
        GLenum error = glGetError();
        if (error != 0) {
            NSLog(@"OVLFilter error %d", error);
        }
        */
    }
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}


@end
