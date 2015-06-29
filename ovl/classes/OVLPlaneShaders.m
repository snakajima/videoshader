//
//  PlaneShaders.m
//
//  Created by Satoshi Nakajima on 9/20/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//
// http://www.gamedev.net/topic/465948-hsl-shader-glsl-code/
// http://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
// http://www.tiltshiftphotography.net/tilt-shift-photography-photoshop-tutorial/
// http://lava360.com/healthy-collection-of-photoshop-tutorials-for-graphic-designers/
// http://www.youtube.com/watch?v=r5WZpT_pOKc
// http://www.youtube.com/watch?v=K43-_zhQZiM

#import "OVLPlaneShaders.h"
#import "OVLNode.h"
#import "OVLFilter.h"
#import "OVLScript.h"
#import "OVLShaderManager.h"

@interface OVLPlaneShaders()  {
    CGSize _sizeTexture, _sizeView;
    GLuint _aPosition, _aTextCoord;
    GLuint _uProjection, _uModelView, _uRatio;
    GLuint _uTexture;
    GLuint _bufVertices, _bufIndices;
    
    GLuint _frameBuffers[MAX_FRAMEBUFCOUNT];
    GLuint _textures[MAX_FRAMEBUFCOUNT]; // only for clean-up
    BOOL _hasRenderTexture;
    NSDate* _date;
    
    // OVL
    NSMutableArray* _nodeList;
    GLuint _ifbRender;
    GLuint _stack[16];
    GLuint _sti;
    BOOL _fLast;
}
@end

@implementation OVLPlaneShaders

typedef struct {
    float Position[3];
    float TextCoord[2];
} MyVertex;

static const GLushort s_indices[] = {
    0, 1, 2, 3
};

static const MyVertex s_vertices[] = {
    { {0.0, 0.0, -10.0}, {0.0, 0.0} },
    { {0.0, 1.0, -10.0 }, {0.0, 1.0} },
    { {1.0, 0.0, -10.0 }, {1.0, 0.0} },
    { {1.0, 1.0, -10.0 }, {1.0, 1.0} }
};

#if TARGET_IPHONE_SIMULATOR
#define SIMPLE_VERTEX @"aspect.vsh"
#else
#define SIMPLE_VERTEX @"aspect_rotation.vsh"
#endif

-(void)_initCommon {
    _date = [NSDate date];
    GLfloat uPixel[] = { 1.0 / _sizeTexture.width, 1.0 / _sizeTexture.height };
    for (OVLNode* node in _nodeList) {
        [node setPixelSize:uPixel delegate:self];
        if ([node isKindOfClass:[OVLFilter class]]) {
            OVLFilter* filter = (OVLFilter*)node;
            if (filter.fAudio) {
                self.fProcessAudio = YES;
            }
        }
    }
    
    glUseProgram(_programHandle);
    _uProjection = glGetUniformLocation(_programHandle, "uProjection");
    _uModelView = glGetUniformLocation(_programHandle, "uModelView");
    _uTexture = glGetUniformLocation(_programHandle, "uTexture");
    _uRatio = glGetUniformLocation(_programHandle, "ratio");
    _aPosition = glGetAttribLocation(_programHandle, "aPosition");
    _aTextCoord = glGetAttribLocation(_programHandle, "aTextCoord");
    glEnableVertexAttribArray(_aPosition);
    glEnableVertexAttribArray(_aTextCoord);

    glGenBuffers(1, &_bufVertices);
    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(s_vertices), s_vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &_bufIndices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufIndices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(s_indices), s_indices, GL_STATIC_DRAW);
    
    for (int i=0; i<MAX_TEXTURE_STACK; i++) {
        [self _createFrameBuffer:i renderTexture:NULL skip:NO];
    }
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
}

-(id) initWithSize:(CGSize)size withNodeList:(NSArray*)nodeList viewSize:(CGSize)viewSize landscape:(BOOL)fLandscape {
    NSString* vertex = fLandscape ? @"upsidedown.vsh" : SIMPLE_VERTEX;
    if (self = [super initWithVertex:vertex fragment:@"simple_cutoff.fsh"]) {
        _sizeTexture = size;
        _sizeView = viewSize;
        _nodeList = [NSMutableArray arrayWithArray:nodeList];
        [self _initCommon];
    }
    return self;
}

// If RenderTexture is specified, it will become the last texture to be rendered.
-(void) setRenderTexture:(CVOpenGLESTextureRef)renderTexture {
    [self _createFrameBuffer:TEXTURE_INDEX_RENDER renderTexture:renderTexture skip:_hasRenderTexture];
    _hasRenderTexture = YES;
}

-(void) _createFrameBuffer:(GLuint)ifb renderTexture:(CVOpenGLESTextureRef)renderTexture skip:(BOOL)skip {
    // Create the framebuffer
    if (!skip) {
        glGenFramebuffers(1, _frameBuffers+ifb);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffers[ifb]);
    
    GLuint texture;
    if (renderTexture) {
        texture = CVOpenGLESTextureGetName(renderTexture);
        glActiveTexture(GL_TEXTURE0 + ifb);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    } else {
        // Create the destination texture
        glGenTextures(1, &texture);
        glActiveTexture(GL_TEXTURE0 + ifb);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // This empty buffer makes Instruments happy (not essential)
        GLubyte * buf = (GLubyte *) calloc(_sizeTexture.width*_sizeTexture.height*4, sizeof(GLubyte));
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _sizeTexture.width, _sizeTexture.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf);
        free(buf);
        
        _textures[ifb] = texture; // only for clean up
    }
    GLenum error = glGetError();
    if (error) {
        NSLog(@"OVLP _createFrameBuffer error=%d", error);
    }
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"OVLP failed to make complete framebuffer object %x, %d", status, glGetError());
    }
}

// This function is called only when the projection matrix changes
-(void) setProjection:(GLKMatrix4*)projection {
    GLKMatrix4 modelView = GLKMatrix4Identity;
    glUseProgram(_programHandle);
    glUniformMatrix4fv(_uProjection, 1, 0, projection->m);
    glUniformMatrix4fv(_uModelView, 1, 0, modelView.m);
#if TARGET_IPHONE_SIMULATOR
    CGFloat ratioTexture = _sizeTexture.height / _sizeTexture.width;
#else
    CGFloat ratioTexture = _sizeTexture.width / _sizeTexture.height;
#endif
    CGFloat ratioView = _sizeView.height / _sizeView.width;
    //NSLog(@"PS ratio=%f",ratioTexture/ratioView);
    glUniform2f(_uRatio, 1.0, ratioView/ratioTexture);
 
    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);
    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), 0);
    glVertexAttribPointer(_aTextCoord, 2, GL_FLOAT, GL_FALSE, sizeof(MyVertex), (GLvoid*) (sizeof(float) * 3));

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufIndices);
}

// <OVLNodeDelegate> method
-(BOOL) hasDepth:(GLuint)depth {
    return (_sti >= depth);
}

// <OVLNodeDelegate> method
-(GLuint) popTexture {
    if (_sti == 0) {
        NSLog(@"PS:popTexture stack underflow");
        return 0;
    }
    return _stack[--_sti];
}

// <OVLNodeDelegate> method
-(GLuint) forkTexture {
    if (_sti == 0) {
        NSLog(@"PS:forkTexture stack underflow");
        return 0;
    }
    return _stack[_sti-1];
}

// <OVLNodeDelegate> method
-(void) pushTexture:(GLuint)index {
    if (_sti+1 > MAX_TEXTURE_STACK) {
        NSLog(@"PS:pushTexture stack overflow");
    }
    _stack[_sti++] = index;
}

-(void) startRecording {
    // _sti = 0; // mostly for motion clipping
}

// <OVLNodeDelegate> method
-(void) inheritTexture {
    if (_sti < 1) {
        NSLog(@"PS:inheritTexture stack underflow");
        return;
    }
    if (_sti == 1) {
        // Handling the very first frame
        _stack[_sti++] = _stack[0];
        return;
    }

    GLuint iBottom = _stack[0];
    for (int i=0; i< _sti-1; i++) {
        _stack[i] = _stack[i+1];
    }
    _stack[_sti-1] = iBottom;
    //NSLog(@"OVLP inheritTexture %d", iBottom);
}

// <OVLNodeDelegate> method
-(void) shiftTexture {
    if (_sti < 2) {
        NSLog(@"PS:shiftTexture stack underflow");
        return;
    }
    GLuint iTop = _stack[_sti-1];
    for (int i = _sti-1; i > 0; i--) {
        _stack[i] = _stack[i-1];
    }
    _stack[0] = iTop;
}

// <OVLNodeDelegate> method
-(void) prepareFrame {
    int flags[MAX_FRAMEBUFCOUNT] = {0};
    for (int j = 0; j < _sti; j++) {
        flags[_stack[j]] = 123;
    }
    _ifbRender = 999;
    for (int j = 0; j < MAX_TEXTURE_STACK; j++) {
        if (flags[j]==0) {
            _ifbRender = j;
            //j = MAX_FRAMEBUFCOUNT;
            break;
        }
    }
    if (_ifbRender >= MAX_TEXTURE_STACK) {
        NSLog(@"OVC prepareFrame ### stack overflow");
        _ifbRender = MAX_TEXTURE_STACK-1;
    }
    if (_fLast) {
        if (_hasRenderTexture) {
            _ifbRender = TEXTURE_INDEX_RENDER;
        }
    }
}

-(void) setSourceTexture:(GLuint)texture {
    glActiveTexture(GL_TEXTURE0 + TEXTURE_INDEX_VIDEOIN);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

// <OVLNodeDelegate> method
-(void) renderRect {
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffers[_ifbRender]);
    glClear(GL_COLOR_BUFFER_BIT);
    [self _render];
    [self pushTexture:_ifbRender];

    GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
}

-(void) process {
    glViewport( 0, 0, _sizeTexture.width, _sizeTexture.height );
    NSUInteger count = _nodeList.count;
    //_sti = 0;
    if (_sti > 0) {
        _sti--;
        if (_sti > 1) {
            _sti = 1;
        }
    }
    [self pushTexture:TEXTURE_INDEX_VIDEOIN];
    
    // Find the last filter node (not control node)
    NSUInteger iLastFilter = count-1;
    for (int index=0; index < count; index++) {
        OVLNode* node = [_nodeList objectAtIndex:index];
        if ([node isKindOfClass:[OVLFilter class]]) {
            iLastFilter = index;
        }
    }
    
    for (int index=0; index < count; index++) {
        //NSLog(@"stack[%d]=%d,%d,%d,%d", _sti, _stack[0], _stack[1], _stack[2], _stack[3]);
        _fLast = (index == iLastFilter);
        OVLNode* node = [_nodeList objectAtIndex:index];
        [node process:self];
    }
    //NSLog(@"stack[%d]=%d,%d,%d,%d", _sti, _stack[0], _stack[1], _stack[2], _stack[3]);
}


// This function is called for each frame
-(void) render {
    glUseProgram(_programHandle);
    glUniform1i(_uTexture, _stack[_sti-1]);
    [self _render];

    GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
}

// This function is called for each frame
-(void) _render {
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(s_indices)/sizeof(s_indices[0]), GL_UNSIGNED_SHORT, 0);
}

-(UIImage*) snapshot:(BOOL)fAdjustSize {
    GLuint iLast = _stack[_sti-1];
    if (iLast == TEXTURE_INDEX_VIDEOIN) {
        NSLog(@"PS:snapshot #### Special case, empty pipeline");
        NSDictionary* extra = @{
            @"pipeline":@[
                @{ @"filter":@"simple" }
            ]
        };
        OVLScript* scriptExtra = [[OVLScript alloc] initWithDictionary:extra];
        OVLNode* node = [scriptExtra.nodes lastObject];
        [node compile];
        //GLfloat uPixel[] = { 1.0 / _sizeTexture.width, 1.0 / _sizeTexture.height };
        //[node setPixelSize:uPixel];
        glViewport( 0, 0, _sizeTexture.width, _sizeTexture.height );
        [node process:self];
        iLast = _stack[_sti-1];
    }

    //UIGraphicsBeginImageContext(size);
    CGSize sizeImage = _sizeTexture;
    if (fAdjustSize && sizeImage.width / 4.0 > sizeImage.height / 3.0) {
        sizeImage.width = sizeImage.height / 3.0 * 4.0;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, sizeImage.width, sizeImage.height, 8, sizeImage.width*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    unsigned char* data = CGBitmapContextGetData(ctx);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffers[iLast]);
    glReadPixels((_sizeTexture.width - sizeImage.width) / 2.0, 0, sizeImage.width, sizeImage.height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    //UIImage* image = [UIImage imageWithCGImage:cgImage];
    //CGImageRelease(cgImage);
    CGContextRelease(ctx);
    UIImage* image= [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

// HACK/INVESTIGATE/WORKAROUND
// If we don't remove _nodeList hear, the clean up code in dealloc (which calls clearProgram)
// makes the "flip" not working any more.
-(void) cleanupNodelist {
    _nodeList = nil;
}

-(void) dealloc {
    NSLog(@"PS dealloc");
    GLuint buffers[] = { _bufVertices, _bufIndices };
    glDeleteBuffers(sizeof(buffers)/sizeof(buffers[0]), buffers);
    
    glDeleteFramebuffers(MAX_FRAMEBUFCOUNT, _frameBuffers);
    glDeleteTextures(MAX_TEXTURE_STACK, _textures);
    for (OVLNode* node in _nodeList) {
        [node clearProgram];
    }
}

-(GLfloat) currentTime {
    NSDate* date = [NSDate date];
    return [date timeIntervalSinceDate:_date];
}

@end
