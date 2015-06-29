//
//  PlaneShaders.h
//
//  Created by Satoshi Nakajima on 9/20/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//

#import "OVLBaseShader.h"
#import "OVLNode.h"

#define MAX_FRAMEBUFCOUNT 8
#define TEXTURE_INDEX_VIDEOIN (MAX_FRAMEBUFCOUNT-1)
#define TEXTURE_INDEX_TEXTURE (MAX_FRAMEBUFCOUNT-2)
#define TEXTURE_INDEX_RENDER (MAX_FRAMEBUFCOUNT-3)
#define MAX_TEXTURE_STACK (MAX_FRAMEBUFCOUNT-3)

@interface OVLPlaneShaders : OVLBaseShader <OVLNodeDelegate>
//@property (nonatomic) GLuint textureSrc;
-(UIImage*) snapshot:(BOOL)fAdjustSize;
-(void) setSourceTexture:(GLuint)texture;
-(void) setRenderTexture:(CVOpenGLESTextureRef)renderTexture;
-(id) initWithSize:(CGSize)size withNodeList:(NSArray*)nodeList viewSize:(CGSize)viewSize landscape:(BOOL)fLandscape;
//-(id) initWithSize:(CGSize)size withScript:(NSURL*)urlScript;
-(void) cleanupNodelist;
-(void) startRecording;
-(void) process;
-(void) setProjection:(GLKMatrix4*)projection;
-(void) render;
@property (nonatomic) BOOL fProcessAudio;
@property (nonatomic) GLfloat audioVolume;
@end
