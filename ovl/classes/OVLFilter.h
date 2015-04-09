//
//  OVLFilter.h
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLNode.h"

@interface OVLFilter : OVLNode {
    GLuint _ph;
    GLint _uTexture;
    GLint _uTime;
    NSString* _fsh, *_vsh;
    NSMutableDictionary* _attrs;
    NSMutableDictionary* _ui;
    NSDictionary* _extra;
    BOOL _fCompiled;
    UIDeviceOrientation _orientation;
    GLint _uOrientation;
    GLint _uAudio;
}
@property (nonatomic) BOOL fork;
@property (nonatomic) NSInteger repeat;
@property (nonatomic) BOOL fOrientation;
@property (nonatomic) BOOL fAudio;
-(id) initWithVertexShader:(NSString*)vsh fragmentShader:(NSString*)fsh;
-(void) innerCompile;
-(void) setUI:(NSDictionary*)ui;
-(void) setExtra:(NSDictionary*)extra;
-(void) deferredSetAttr:(id)value forName:(NSString*)name;
-(void) processOrientation;
+(void) setFrontCameraMode:(BOOL)flag;
+(BOOL) isFrontCameraMode;
@end
