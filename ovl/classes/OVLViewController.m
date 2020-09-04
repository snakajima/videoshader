//
//  OpenGLViewController.m
//
//  Created by Satoshi Nakajima on 9/23/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//
// http://stackoverflow.com/questions/5808557/avassetwriterinputpixelbufferadaptor-and-cmtime
// http://stackoverflow.com/questions/9550297/faster-alternative-to-glreadpixels-in-iphone-opengl-es-2-0/9704392#9704392
//

#import <Accelerate/Accelerate.h>
#import "OVLViewController.h"
#import "OVLPlaneShaders.h"
#import "OVLScript.h"
#import "OVLTexture.h"
#import "OVLFilter.h"


@interface OVLViewController () {
    IBOutlet GLKView* _glkView;
    OVLPlaneShaders* _shader;
    OVLScript* _script;
    CGSize _size;
    BOOL _fInitializingShader;
    CGFloat _clipRatio;
    
    AVCaptureSession* _captureSession;
    CVOpenGLESTextureCacheRef _textureCache;    
    AVCaptureVideoDataOutput* _videoOutput;
    AVCaptureAudioDataOutput* _audioOutput;
    AVCaptureStillImageOutput* _stillImageOutput;
    CVOpenGLESTextureRef _videoTexture;
    
    AVCaptureDeviceInput *_inputCamera;
    AVCaptureDevice* _camera;
    
    //
    AVAssetWriter* _videoWriter;
    AVAssetWriterInput* _videoInput;
    AVAssetWriterInputPixelBufferAdaptor* _adaptor;
    AVAssetWriterInput* _audioInput;
    BOOL _fFirstFrame;
    //NSDate* _startTime;
    CMTime _timeStamp, _startTime;
    BOOL _fUpdated;
    NSInteger _duration;
    // Fast buffer
    CVPixelBufferRef _renderPixelBuffer;
    CVOpenGLESTextureRef _renderTexture;
    // External display support
    GLuint _frameBufferEx;
    //GLuint _programHandleEx;
    //GLuint _uTextureEx;
    
    // FFT
    FFTSetup _fftSetup;
    DSPSplitComplex _fftA;
    CMItemCount _fftSize;
    
    // assetSrc
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput* _assetReaderOutput;
    AVAssetReaderAudioMixOutput *_audioMixOutput;
    //BOOL _fFirstBufferIsAlreadyCaptured;
    CGAffineTransform _assetTransform;
}
@end

@implementation OVLViewController
@dynamic camera;
@dynamic duration;
@dynamic context;
@dynamic glkView;

-(AVCaptureSession*) session {
    return _captureSession;
}

-(GLKView*) glkView {
    return _glkView;
}

/*
+(NSString*) tempFileName:(NSString*)extension {
    static NSUInteger s_index = 0;
    s_index = (s_index + 1) % 8;
    return [NSString stringWithFormat:@"videoshader%lu.%@", (unsigned long)s_index, extension];
}
*/

+(NSString*) tempFilePath:(NSString*)extension {
    static NSUInteger s_index = 0;
    static NSString* s_pathFolder = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (s_pathFolder == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *pathFolder = [paths objectAtIndex:0];
        NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        s_pathFolder = [pathFolder stringByAppendingPathComponent:appID];
        s_pathFolder = [s_pathFolder stringByAppendingPathComponent:@"vmTemp"];
        if ([fm fileExistsAtPath:s_pathFolder]) {
            // LATER: empty this directory
        }
    }
    if (![fm fileExistsAtPath:s_pathFolder]) {
        [fm createDirectoryAtPath:s_pathFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    s_index = (s_index + 1) % 100; // large number is fine as long as we delete them.
    NSString* filename = [NSString stringWithFormat:@"%lu.%@", (unsigned long)s_index, extension];
    return [s_pathFolder stringByAppendingPathComponent:filename];
}

-(EAGLContext*) context {
    return _glkView.context;
}

-(NSInteger) duration {
    return _duration;
}

-(AVCaptureDevice*) camera {
    return _camera;
}

+(NSString*) didFinishWritingVideo {
    static NSString* s_str = @"didFinishWritingVideo";
    return s_str;
}

+(NSString*) didUpdateDuration {
    static NSString* s_str = @"didUpdateDuration";
    return s_str;
}

+(NSString*) didRecordFrame {
    static NSString* s_str = @"didRecordFrame";
    return s_str;
}

-(void) _setupVideoCaptureSession {
    _captureSession = [[AVCaptureSession alloc] init];
    
    /* By default, AVCaptureSession will configure your AVAudioSession optimally for recording when your AVCaptureSession is using the microphone. Set the automaticallyConfiguresApplicationAudioSession property to NO to override the default behavior and the AVCaptureDevice will use your current AVAudioSession settings without altering them. */
    //_captureSession.automaticallyConfiguresApplicationAudioSession = NO;
    AVCaptureDevice* microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (microphone) {
        NSError* error = nil;
        AVCaptureDeviceInput * microphone_input = [AVCaptureDeviceInput deviceInputWithDevice:microphone error:&error];
        if (microphone_input) {
            [_captureSession addInput:microphone_input];
            
            _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
            [_audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            [_captureSession addOutput:_audioOutput];
        } else {
            NSLog(@"OVLVC no microphone %@", error);
        }
    }

    [self _addCamera]; // front

    if (_inputCamera) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.videoSettings = @{
            (id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
        };
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [_captureSession addOutput:_videoOutput];
        for (AVCaptureConnection* connection in _videoOutput.connections) {
            if (connection.isVideoOrientationSupported) {
                //connection.videoOrientation = [[UIDevice currentDevice] orientation];
            }
        }
        
        // For still image
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_stillImageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
        if (![_captureSession canAddOutput:_stillImageOutput]) {
            NSLog(@"OVLVC Can't add stillImageOutput");
        }
        [_captureSession addOutput:_stillImageOutput];

        [_captureSession startRunning];

        if (self.fps > 0) {
            [_camera lockForConfiguration:nil];
            _camera.activeVideoMinFrameDuration = CMTimeMake(1, self.fps);
            [_camera unlockForConfiguration];
        }
    }
}

-(void) _addCamera {
    AVCaptureDevicePosition position = self.fFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    _camera = nil;
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        //NSLog(@"MNC Device name: %@", [device localizedName]);
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if (!_camera || ([device position] == position)) {
                _camera = device;
            }
        }
    }
    NSError *error = nil;
    if (_camera) {
        NSString* preset = AVCaptureSessionPreset1280x720;
        if ([_camera supportsAVCaptureSessionPreset:preset]) {
            _captureSession.sessionPreset = preset;
        } else {
            NSLog(@"VC falling back to medium resolution %@", preset);
            _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        }
        _inputCamera = [AVCaptureDeviceInput deviceInputWithDevice:_camera error:&error];
        if (_inputCamera) {
            [_captureSession addInput:_inputCamera];
        }
        _glkView.transform = (_camera.position==AVCaptureDevicePositionFront) ? CGAffineTransformMakeScale(-1.0, 1.0) : CGAffineTransformIdentity;
    }
}

-(IBAction) resetShader {
    [_shader cleanupNodelist];
    _shader = nil;
    [self _tearDownRenderTarget];
    /*
    [_script compile];
    
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glkView.context, NULL, &_textureCache);
    */
}

-(void) switchFPS:(int32_t)fps {
    self.fps = fps;
    [_camera lockForConfiguration:nil];
    _camera.activeVideoMaxFrameDuration = CMTimeMake(1, self.fps);
    _camera.activeVideoMinFrameDuration = CMTimeMake(1, self.fps);
    [_camera unlockForConfiguration];
}

-(IBAction) updateCameraPosition:(BOOL)fFront {
    self.fFrontCamera = fFront;
    [_captureSession removeInput:_inputCamera];
    _inputCamera = nil;
    [self resetShader];
    [self _addCamera];
}


- (void)viewDidLoad {
    [super viewDidLoad];

#if 1
    // Initialize FFT
    _fftSetup = vDSP_create_fftsetup(11, kFFTRadix2);
#endif

    // Initialize the view's layer
    _glkView.contentScaleFactor = [UIScreen mainScreen].scale;
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)_glkView.layer;
    eaglLayer.opaque = YES;
    eaglLayer.contentsScale = _glkView.contentScaleFactor;

    // Initialize the context
    _glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_glkView.context || ![EAGLContext setCurrentContext:_glkView.context]) {
        NSLog(@"Failed to initialize or set current OpenGL context");
        exit(1);
    }
    
    self.maxDuration = kCMTimeIndefinite;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIApplication* app = [UIApplication sharedApplication];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:app];
}

-(void) _didEnterBackground:(NSNotification*)n {
    NSLog(@"OVLV enter background");
    [self resetShader];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

-(void) switchScript:(OVLScript*)script {
    _shader = nil;
    _script = script;
    [_script compile];
    
#if TARGET_IPHONE_SIMULATOR
    UIImage* image = [UIImage imageNamed:@"Lenna.png"];
    [self _initShader:image.size];
#endif
}

-(void) loadScript:(OVLScript*)script {
    _script = script;
    [_script compile];
#if TARGET_IPHONE_SIMULATOR
    UIImage* image = [UIImage imageNamed:@"Lenna.png"];
    NSError* err = nil;
    GLKTextureInfo* textureDebug = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&err];
    if (err) {
        NSLog(@"OVC textureOrg %@", err);
    }
    glActiveTexture(GL_TEXTURE0 + TEXTURE_INDEX_VIDEOIN);
    glBindTexture(GL_TEXTURE_2D, textureDebug.name);
#endif

    
#if 0
    GLint cTextures = 0;
    glGetIntegerv(GL_MAX_TEXTURE_UNITS, &cTextures);
    NSLog(@"OVC cTextures=%d", cTextures);
#endif

    // Initialize the view's properties
    _glkView.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    //_glkView.drawableMultisample = GLKViewDrawableMultisample4X;
    _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGB565;

    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glkView.context, NULL, &_textureCache);
    if (self.assetSrc) {
        _assetReader = [AVAssetReader assetReaderWithAsset:self.assetSrc error:nil];
        NSArray *videoTracks = [self.assetSrc tracksWithMediaType:AVMediaTypeVideo];
        NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
        AVAssetTrack* videoTrack = videoTracks[0];
        _assetTransform = videoTrack.preferredTransform;
        _assetReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:settings];
        //[AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:settings];
        [_assetReader addOutput:_assetReaderOutput];

        NSArray *audioTracks = [self.assetSrc tracksWithMediaType:AVMediaTypeAudio];
        if (audioTracks.count > 0) {
            NSLog(@"OVLVC has audioTracks, %lu", (unsigned long)audioTracks.count);
            NSDictionary *decompressionAudioSettings = @{ AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM] };
            _audioMixOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:decompressionAudioSettings];
            AVMutableAudioMix* mutableAudioMix = [AVMutableAudioMix audioMix];
            _audioMixOutput.audioMix = mutableAudioMix;
            [_assetReader addOutput:_audioMixOutput];
        }
        [_assetReader startReading];

        [self _setInitialSize:videoTrack.naturalSize];
        /*
        // We need to read at least one frame to initilize the shader
        if (_assetReader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef buffer = [_assetReaderOutput copyNextSampleBuffer];
            CMTime t = CMSampleBufferGetPresentationTimeStamp(buffer);
            NSLog(@"OVLVC processing the very first frame t=%.2f", (double)t.value / (double)t.timescale);
            [self captureOutput:nil didOutputSampleBuffer:buffer fromConnection:nil];
            CFRelease(buffer);
            _fFirstBufferIsAlreadyCaptured = YES;
        }
        */
    } else {
        [self _setupVideoCaptureSession];
    }
    
    // deferred
#if TARGET_IPHONE_SIMULATOR
    [self _initShader:image.size];
#endif
}

-(void) _initShader:(CGSize)size {
    NSLog(@"OVC _initShader: %.0f,%.0f", size.width, size.height);
    
    NSArray* nodes = _script.nodes;
    if (_clipRatio > 1.0) {
        //NSLog(@"OVC _clipRatio is %f", _clipRatio);
        NSDictionary* extra = @{
            @"pipeline":@[
                @{ @"filter":@"stretch", @"attr":@{
                    @"ratio":@[@1.0, [NSNumber numberWithFloat:_clipRatio]] } },
            ]
        };
        OVLScript* scriptExtra = [[OVLScript alloc] initWithDictionary:extra];
        [scriptExtra compile];
        NSMutableArray* nodesNew = [NSMutableArray arrayWithArray:scriptExtra.nodes];
        [nodesNew addObjectsFromArray:nodes];
        nodes = nodesNew;
    }
    if (self.fWatermark) {
        NSDictionary* extra = @{
            @"pipeline":@[
                @{ @"filter":@"watermark",
                    /*@"extra": @{
                        @"orientation":@YES,
                    },*/
                    @"attr":@{
                        @"scale":[NSNumber numberWithFloat:50.0/480.0 /*size.height*/],
                        @"ratio":@0.7,
                        //@"position":@[@0.5, @0.5]
                    }
                }
            ]
        };
        OVLScript* scriptExtra = [[OVLScript alloc] initWithDictionary:extra];
        [scriptExtra compile];
        NSMutableArray* nodesNew = [NSMutableArray arrayWithArray:nodes];
        [nodesNew addObjectsFromArray:scriptExtra.nodes];
        nodes = nodesNew;
    }
    if (self.imageTexture) {
        //NSLog(@"OVLVC imageOrientation %d", self.imageTexture.imageOrientation);
        NSDictionary* extra = @{
            @"pipeline":@[
                @{ @"source":@"texture" },
                @{ @"filter":@"rotation" },
                @{ @"filter":@"stretch" },
                @{ @"filter":@"timedzoom" },
            ]
        };
        OVLScript* scriptExtra = [[OVLScript alloc] initWithDictionary:extra];
        OVLTexture* nodeTexture = [scriptExtra.nodes objectAtIndex:0];
        if ([nodeTexture isKindOfClass:[OVLTexture class]]) {
            // taking the orientation out
            UIGraphicsBeginImageContextWithOptions(self.imageTexture.size, NO, self.imageTexture.scale);
            [self.imageTexture drawInRect:(CGRect){0, 0, self.imageTexture.size}];
            nodeTexture.imageTexture = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        OVLFilter* nodeRotation = [scriptExtra.nodes objectAtIndex:1];
        OVLFilter* nodeStretch = [scriptExtra.nodes objectAtIndex:2];
        float angle = 0.0;
        //CGImageRef imageRef = self.imageTexture.CGImage;
        //CGSize size = { CGImageGetWidth(imageRef), CGImageGetHeight(imageRef) };
        CGSize size = nodeTexture.imageTexture.size;
        CGSize sizeOut = { 9.0, 16.0 };
        float ratioX = size.width / sizeOut.width;
        float ratioY = size.height / sizeOut.height;
        switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = M_PI;
            // fall through
        default:
            ratioX = size.height / sizeOut.width;
            ratioY = size.width / sizeOut.height;
            break;
        }
        if (ratioX < ratioY) {
            ratioY = ratioY / ratioX;
            ratioX = 1.0;
        } else {
            ratioX = ratioX / ratioY;
            ratioY = 1.0;
        }
        [nodeRotation setAttr:[NSNumber numberWithFloat:angle] forName:@"angle"];
        [nodeStretch setAttr:@[[NSNumber numberWithFloat:ratioX], [NSNumber numberWithFloat:ratioY]] forName:@"ratio"];
        
        [scriptExtra compile];
        NSMutableArray* nodesNew = [NSMutableArray arrayWithArray:scriptExtra.nodes];
        [nodesNew addObjectsFromArray:nodes];
        nodes = nodesNew;
    }
    
    if (nodes.count == 0) {
        NSLog(@"OVC _initShader: ### special case, empty pipeline");
        NSDictionary* extra = @{
            @"pipeline":@[
                @{ @"filter":@"simple" }
            ]
        };
        OVLScript* scriptExtra = [[OVLScript alloc] initWithDictionary:extra];
        [scriptExtra compile];
        nodes = scriptExtra.nodes;
    }

    _shader = [[OVLPlaneShaders alloc] initWithSize:size withNodeList:nodes viewSize:_glkView.bounds.size landscape:self.fLandscape];
  
    // Set the initial projection to all the shaders
    GLKMatrix4 matrix = GLKMatrix4MakeOrtho(0.0, 1.0, 1.0, 0.0, 1.0, 100.0);
    [_shader setProjection:&matrix];

    if (_renderPixelBuffer) {
        NSLog(@"OVLVC _initShader calling setRenderTexture");
        [_shader setRenderTexture:_renderTexture];
    }
}

-(BOOL) _readAssetBuffer {
    BOOL fSkipShader = YES;
    /*if (_fFirstBufferIsAlreadyCaptured) {
        _fFirstBufferIsAlreadyCaptured = NO;
        fSkipShader = NO;
    } else */
    if (_fUpdated && self.fRecording) {
        NSLog(@"OVL _readAssetBuffer, pending writing");
        [self _writeToBuffer];
    } else if (_assetReader.status == AVAssetReaderStatusReading) {
        BOOL fProcessing = NO;
        CMSampleBufferRef buffer = [_assetReaderOutput copyNextSampleBuffer];
        if (buffer) {
            CMTime t = CMSampleBufferGetPresentationTimeStamp(buffer);
            NSLog(@"OVLVC video t=%.2f", (double)t.value / (double)t.timescale);
            [self captureOutput:nil didOutputSampleBuffer:buffer fromConnection:nil];
            CFRelease(buffer);
            fSkipShader = NO;
            fProcessing = YES;
        } else {
            NSLog(@"OVLVC -- video done");
        }
        
        if (_audioMixOutput) {
            // We can't process audio until we call _writeToBuffer at least once
            if (!_fFirstFrame && _audioInput.readyForMoreMediaData) {
                CMSampleBufferRef buffer = [_audioMixOutput copyNextSampleBuffer];
                if (buffer) {
                    CMTime t = CMSampleBufferGetPresentationTimeStamp(buffer);
                    NSLog(@"OVLVC audio t=%.2f", (double)t.value / (double)t.timescale);
                    [_audioInput appendSampleBuffer:buffer];
                    CFRelease(buffer);
                    fProcessing = YES;
                } else {
                    NSLog(@"OVLVC -- audio done");
                    _audioMixOutput = nil;
                }
            } else {
                fProcessing = YES;
            }
        }
        if (!fProcessing) {
            NSLog(@"OVLVC -- all done");
            _assetReaderOutput = nil;
            _assetReader = nil;
            [self resetShader];
            if (self.fRecording) {
                [self _stopRecording];
            }
        }
    } else {
        NSLog(@"OVLVC -- stop");
    }
    return fSkipShader;
}


// <GLKViewDelegate> method
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (!_shader) {
        // We don't want to do anything if the shader is not initialized yet.
        return;
    }
    
    if (_assetReader && self.fRecording) {
        BOOL fSkipShader = [self _readAssetBuffer];
        if (fSkipShader) {
            return;
        }
    }
    
    //NSLog(@"OVLVL drawInRect shading");
    [_shader process];
    
    [view bindDrawable];
    glClearColor(0.333, 0.333, 0.333, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
    [_shader render];
    
    if (self.fRecording) {
        [self _writeToBuffer];
    }
    
    if (self.renderbufferEx) {
        if (!_frameBufferEx) {
            glGenFramebuffers(1, &_frameBufferEx);
            /*
            _programHandleEx = [OVLBaseShader compileAndLinkShader:@"simple.vsh" fragment:@"simple.fsh"];
            GLuint uProjection = glGetUniformLocation(_programHandleEx, "uProjection");
            GLuint uModelView = glGetUniformLocation(_programHandleEx, "uModelView");
            //GLuint uRatio = glGetUniformLocation(_programHandleEx, "ratio");
            _uTextureEx = glGetUniformLocation(_programHandleEx, "uTexture");
            //_uRatio = glGetUniformLocation(_programHandle, "ratio");
            //_aPosition = glGetAttribLocation(_programHandle, "aPosition");
            //_aTextCoord = glGetAttribLocation(_programHandle, "aTextCoord");
            GLKMatrix4 modelView = GLKMatrix4Identity;
            GLKMatrix4 projection = GLKMatrix4MakeOrtho(0.0, 1.0, 1.0, 0.0, 1.0, 100.0);
            glUseProgram(_programHandleEx);
            glUniformMatrix4fv(uProjection, 1, 0, projection.m);
            glUniformMatrix4fv(uModelView, 1, 0, modelView.m);
            //glUniform2f(uRatio, 1.0, 1.0);
            */
        }
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferEx);
        glClearColor(0.333, 0.333, 0.333, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glBindRenderbuffer(GL_RENDERBUFFER, self.renderbufferEx);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
            GL_RENDERBUFFER, self.renderbufferEx);
        //[_shader renderWithProgram:_programHandleEx texture:_uTextureEx];
        [_shader render];
        [_glkView.context presentRenderbuffer:GL_RENDERBUFFER];
        [view bindDrawable];
    }
}

-(void) _setInitialSize:(CGSize)size {
    _size = size;
    if (!self.fHD) {
        // NOTE: Using floor add a green line at the bottom
        _size.width = ceil(480.0 * _size.width / _size.height);
        _size.height = 480.0;
    }
    _clipRatio = 1.0;
    if (self.fPhotoRatio) {
        CGFloat width = _size.height / 3.0 * 4.0;
        if (_size.width > width + 1.0) {
            _clipRatio = _size.width / width;
            _size.width = width;
            //NSLog(@"OVL capture size adjusted to %f,%f", _size.width, _size.height);
        }
    }
    
    if (_assetReader) {
        _fInitializingShader = NO;
        [self _initShader:_size];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            _fInitializingShader = NO;
            [self _initShader:_size];
        });
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (captureOutput == _videoOutput || _assetReader) {
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        _timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        if (!_shader && _script && !_fInitializingShader) {
            _fInitializingShader = YES;
            // NOTE: We assumes that the camera is always in the landscape mode.
            [self _setInitialSize:CGSizeMake(width, height)];
        }
        
        [self _cleanUpTextures];
        
        // Create a live binding between the captured pixelBuffer and an openGL texture
        CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,    // allocator
            _textureCache,     // texture cache
            pixelBuffer,            // source Image
            NULL,                   // texture attributes
            GL_TEXTURE_2D,          // target
            GL_RGBA,                // internal format
            (int)width,             // width
            (int)height,            // height
            GL_BGRA,                // format
            GL_UNSIGNED_BYTE,       // type
            0,                      // planeIndex
            &_videoTexture);        // texture out
        if (err) {
            NSLog(@"OVLVC Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }   

        [_shader setSourceTexture:CVOpenGLESTextureGetName(_videoTexture)];
        _fUpdated = YES;

    } else if (captureOutput == _audioOutput) {
        if (_shader.fProcessAudio) {
            // http://stackoverflow.com/questions/14088290/passing-avcaptureaudiodataoutput-data-into-vdsp-accelerate-framework/14101541#14101541
            // Pitch detection
            // http://stackoverflow.com/questions/7181630/fft-on-iphone-to-ignore-background-noise-and-find-lower-pitches?lq=1
            // https://github.com/irtemed88/PitchDetector/blob/master/RIOInterface.mm
            // get a pointer to the audio bytes
            CMItemCount numSamples = CMSampleBufferGetNumSamples(sampleBuffer);
            CMBlockBufferRef audioBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t lengthAtOffset;
            size_t totalLength;
            char *samples;
            CMBlockBufferGetDataPointer(audioBuffer, 0, &lengthAtOffset, &totalLength, &samples);

            CMAudioFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
            const AudioStreamBasicDescription *desc = CMAudioFormatDescriptionGetStreamBasicDescription(format);
            if (desc->mFormatID == kAudioFormatLinearPCM) {
                if (desc->mChannelsPerFrame == 1 && desc->mBitsPerChannel == 16) {
/*
                    NSInteger total = 0;
                    short* values = (short*)samples;
                    for (int i=0; i<numSamples; i++) {
                        total += abs(values[i]);
                    }
                    _shader.audioVolume = (float)total/(float)numSamples/(float)0x4000;
*/
                    // Convert it to float vector
                    if (_fftSize ==0) {
                        _fftA.realp = malloc(numSamples * sizeof(float));
                        _fftA.imagp = malloc(numSamples * sizeof(float));
                        _fftSize = numSamples;
                    } else if (_fftSize < numSamples) {
                        _fftA.realp = realloc(_fftA.realp, numSamples * sizeof(float));
                        _fftA.imagp = realloc(_fftA.imagp, numSamples * sizeof(float));
                        _fftSize = numSamples;
                    }
                    vDSP_vflt16((short *)samples, 1, _fftA.realp, 1, numSamples);
                    
                    float scale = 1.0 / 0x7fff;
                    vDSP_vsmul(_fftA.realp, 1, &scale, _fftA.realp, 1, numSamples);
                    float maxValue;
                    vDSP_maxv(_fftA.realp, 1, &maxValue, numSamples);
                    _shader.audioVolume = maxValue;
                    
                    //NSLog(@"OVLVC s1=%.2f, %.2f, %.2f, %.2f, %.2f, %.2f", _fftA.realp[0], _fftA.realp[1], _fftA.realp[2], _fftA.realp[3], _fftA.realp[4], _fftA.realp[5]);
                    float a = 0.0;
                    vDSP_vfill(&a, _fftA.imagp, 1, numSamples);
                    //NSLog(@"OVLVC s2=%.2f, %.2f, %.2f, %.2f, %.2f, %.2f", _fftA.imagp[0], _fftA.imagp[1], _fftA.imagp[2], _fftA.imagp[3], _fftA.imagp[4], _fftA.imagp[5]);
                    vDSP_Length log2n = log2(numSamples);
                    vDSP_fft_zrip(_fftSetup, &_fftA, 1, log2n, FFT_FORWARD);
                    
                    /*
                    scale = 1.0 / (2 * numSamples);
                    vDSP_vsmul(_fftA.realp, 1, &scale, _fftA.realp, 1, numSamples/2);
                    vDSP_vsmul(_fftA.imagp, 1, &scale, _fftA.imagp, 1, numSamples/2);
                    */
                    
                    //NSLog(@"OVLVC s3=%.2f, %.2f, %.2f, %.2f, %.2f, %.2f", _fftA.realp[0], _fftA.realp[1], _fftA.realp[2], _fftA.realp[3], _fftA.realp[4], _fftA.realp[5]);
                    maxValue = 0.0;
                    int maxIndex = -1;
                    for (int i=0; i < numSamples/2; i++) {
                        float value = _fftA.realp[i] * _fftA.realp[i] + _fftA.imagp[i] * _fftA.imagp[i];
                        if (value > maxValue) {
                            maxValue = value;
                            maxIndex = i;
                        }
                    }
                    NSLog(@"OVLVC maxIndex=%d", maxIndex);
                } else {
                    // handle other cases as required
                }
            }
        }
    
        if (self.fRecording && _audioInput && !_fFirstFrame) {
            //NSLog(@"OGL _audioOutput");
            [_audioInput appendSampleBuffer:sampleBuffer];
        }
    }
}

- (void)_cleanUpTextures
{    
    if (_videoTexture) {
        //glActiveTexture(GL_TEXTURE7);
        //glBindTexture(CVOpenGLESTextureGetTarget(_videoTexture), 0);
        CFRelease(_videoTexture);
        _videoTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
}

-(void) _tearDownRenderTarget {
    if (_renderPixelBuffer) {
        CVPixelBufferRelease(_renderPixelBuffer);
        _renderPixelBuffer = NULL;
        if (_renderTexture) {
            CFRelease(_renderTexture);
            _renderTexture = NULL;
        }
    }
}

- (void) _tearDownAVCapture {
    [self _cleanUpTextures];
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

// NOTE: It calls back synchronously if there is no need for a sound.
-(void) snapshot:(BOOL)sound callback:(void (^)(UIImage* image))callback {
    if (sound) {
        [_stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageOutput.connections.lastObject completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSLog(@"OVLVC still image captured (not used at this moment, just using the sound)");
            UIImage* image = [_shader snapshot:YES];
            callback(image);
        }];
    } else {
        UIImage* image = [_shader snapshot:YES];
        callback(image);
    }
}

- (CGFloat)_angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat angle = 0.0;
    
    switch (orientation) {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
 
    return angle;
}
 
- (CGAffineTransform)_transformFromCurrentVideoOrientation:(AVCaptureVideoOrientation)videoOrientation toOrientation:(AVCaptureVideoOrientation)orientation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
 
    // Calculate offsets from an arbitrary reference orientation (portrait)
    if (_camera.position==AVCaptureDevicePositionFront) {
        if (orientation == AVCaptureVideoOrientationLandscapeLeft) {
            orientation = AVCaptureVideoOrientationLandscapeRight;
        } else if (orientation == AVCaptureVideoOrientationLandscapeRight) {
            orientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
    CGFloat orientationAngleOffset = [self _angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self _angleOffsetFromPortraitOrientationToOrientation:videoOrientation];
    
    // Find the difference in angle between the passed in orientation and the current video orientation
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    
    return transform;
}

-(BOOL) isReadyToRecord {
    return (_size.width > 0);
}

-(void) _startRecording {
    if (![self isReadyToRecord]) {
        NSLog(@"OVLVC _size is not yet initialized.");
        return;
    }
    self.fRecording = YES;
    [_shader startRecording];
    
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *pathFolder = [paths objectAtIndex:0];
    self.urlVideo = [NSURL fileURLWithPath:[pathFolder stringByAppendingPathComponent:[OVLViewController tempFileName:@"mov"]]];
    */
    self.urlVideo = [NSURL fileURLWithPath:[OVLViewController tempFilePath:@"mov"]];
    NSFileManager* manager = [NSFileManager defaultManager];
    [manager removeItemAtURL:self.urlVideo error:nil];
    NSError* error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:self.urlVideo fileType:AVFileTypeQuickTimeMovie
error:&error];
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
        outputSettings:@{
          AVVideoCodecKey:AVVideoCodecH264,
          //AVVideoCompressionPropertiesKey:compression,
          AVVideoWidthKey:[NSNumber numberWithInt:_size.width],
          AVVideoHeightKey:[NSNumber numberWithInt:_size.height]
        }];
    
    if (_assetReader) {
        _videoInput.transform = _assetTransform;
        _videoInput.expectsMediaDataInRealTime = YES;
    } else {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        switch([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
        }
        _videoInput.transform = [self _transformFromCurrentVideoOrientation:AVCaptureVideoOrientationLandscapeRight
                                    toOrientation:orientation];
        _videoInput.expectsMediaDataInRealTime = YES;
    }
    [_videoWriter addInput:_videoInput];

    NSDictionary* attr = @{
        (id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
        (id)kCVPixelBufferWidthKey: [NSNumber numberWithInteger:_size.width],
        (id)kCVPixelBufferHeightKey: [NSNumber numberWithInteger:_size.height]
    };
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoInput sourcePixelBufferAttributes:attr];
    
    if (!self.fNoAudio) {
        // Configure the channel layout as stereo.
        AudioChannelLayout stereoChannelLayout = {
            .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
            .mChannelBitmap = 0,
            .mNumberChannelDescriptions = 0
        };
        // Convert the channel layout object to an NSData object.
        NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout
                          length:offsetof(AudioChannelLayout, mChannelDescriptions)];
        NSDictionary* audioSettings = @{
            AVFormatIDKey: [NSNumber numberWithUnsignedInt:kAudioFormatMPEG4AAC],
            AVEncoderBitRateKey  : [NSNumber numberWithInteger:128000],
            AVSampleRateKey : [NSNumber numberWithInteger:44100],
            AVChannelLayoutKey : channelLayoutAsData,
            AVNumberOfChannelsKey : [NSNumber numberWithUnsignedInteger:2]
        };
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        [_videoWriter addInput:_audioInput];
    }

    [_videoWriter startWriting];
    _fFirstFrame = YES;
    _duration = 0;

    if (_renderPixelBuffer == NULL) {
        NSLog(@"OGLVC creating a new _renderTexture");
        CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, [_adaptor pixelBufferPool], &_renderPixelBuffer);
        if ((_renderPixelBuffer == NULL) || (status != kCVReturnSuccess)) {
            NSLog(@"OVLVC can't create pixel buffer %d", status);
            return;
        }

        // Create a live binding between _renderPixelBuffer and an openGL texture
        CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                    _textureCache,
                                                    _renderPixelBuffer,
                                                    NULL, // texture attributes
                                                    GL_TEXTURE_2D,
                                                    GL_RGBA, // opengl format
                                                    (int)_size.width,
                                                    (int)_size.height,
                                                    GL_BGRA, // native iOS format
                                                    GL_UNSIGNED_BYTE,
                                                    0,
                                                    &_renderTexture);
    
        [_shader setRenderTexture:_renderTexture];
    } else {
        //NSLog(@"OGLVC reusing _renderTexture");
    }
    
    //NSLog(@"startingWriting at %lld", _timeStamp.value);
    //[self _writeToBuffer];
}

-(void) _stopRecording {
    self.fRecording = NO;
    [_videoInput markAsFinished];
    //NSLog(@"finishig %ld", (long)_videoWriter.status);
    [_videoWriter finishWritingWithCompletionHandler:^{
        //NSLog(@"done");
        dispatch_async(dispatch_get_main_queue(), ^{
            _videoWriter = nil;
            _videoInput = nil;
            _audioInput = nil;
            _adaptor = nil;
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:[OVLViewController didFinishWritingVideo] object:self];
        });
    }];
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
        NSLog(@"finish failed %@", _videoWriter.error);
    }
}

-(IBAction) record {
    if (!self.fRecording) {
        [self _startRecording];
    } else {
        [self _stopRecording];
    }
}

-(void) _writeToBuffer {
    if (_fUpdated && _videoInput.readyForMoreMediaData) {
        glFlush(); // Making it sure that GPU won't update the texture particially
        
        _fUpdated = NO;
        CMTime timeStamp = _timeStamp;
        if (_fFirstFrame) {
            _fFirstFrame = NO;
            [_videoWriter startSessionAtSourceTime:_timeStamp];
            _startTime = _timeStamp;
            _duration = -1; // to force the notification
        } else if (self.speed > 0) {
            CMTime delta = CMTimeSubtract(_timeStamp, _startTime);
            delta.value /= self.speed;
            timeStamp = CMTimeAdd(_startTime, delta);
        }
#if 1
        //NSLog(@"OVLVC _write t=%.2f", (double)timeStamp.value / (double)timeStamp.timescale);
        [_adaptor appendPixelBuffer:_renderPixelBuffer withPresentationTime:timeStamp];
#else
        CVPixelBufferRef pixel_buffer = NULL;

        CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, [_adaptor pixelBufferPool], &pixel_buffer);
        if ((pixel_buffer == NULL) || (status != kCVReturnSuccess))
        {
            NSLog(@"can't create pixel buffer %d", status);
            return;
        }
        
        CVPixelBufferLockBaseAddress(pixel_buffer, 0);
        GLubyte *pixelBufferData = (GLubyte *)CVPixelBufferGetBaseAddress(pixel_buffer);
        glReadPixels(0, 0, s_size.width, s_size.height, GL_RGBA, GL_UNSIGNED_BYTE, pixelBufferData);
        CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);

        // May need to add a check here, because if two consecutive times with the same value are added to the movie, it aborts recording

        //NSLog(@"Recorded pixel buffer at time: %lld", _timeStamp.value);
        if(![_adaptor appendPixelBuffer:pixel_buffer withPresentationTime:_timeStamp])
        {
            NSLog(@"Problem appending pixel buffer at time: %lld", _timeStamp.value);
        } 

        CVPixelBufferRelease(pixel_buffer);
#endif
        self.timeRecorded = CMTimeSubtract(_timeStamp, _startTime);
        NSInteger d = (NSInteger)(self.timeRecorded.value / self.timeRecorded.timescale); // interested in only sec.
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:[OVLViewController didRecordFrame] object:self];
        if (d > _duration) {
            _duration = d;
            //NSLog(@"_writeToBuffer writing %d, %lu", _fUpdated, (unsigned long)_duration);
            [center postNotificationName:[OVLViewController didUpdateDuration] object:self];
        }
        
        if (CMTimeCompare(self.timeRecorded, _maxDuration) != -1) {
            NSLog(@"OVL stopping at %lld, %d", self.timeRecorded.value, self.timeRecorded.timescale);
            [self _stopRecording];
        }
    } else {
        //NSLog(@"_writeToBuffer skipping %d", _fUpdated);
    }
}

-(void) dealloc {
    [self _tearDownAVCapture];
    [self _tearDownRenderTarget];
    if (_frameBufferEx) {
        glDeleteFramebuffers(1, &_frameBufferEx);
    }
    vDSP_destroy_fftsetup(_fftSetup);
    if (_fftSize > 0) {
        free(_fftA.realp);
        free(_fftA.imagp);
    }
}

@end
