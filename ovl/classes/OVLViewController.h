//
//  OpenGLViewController.h
//
//  Created by Satoshi Nakajima on 9/23/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
    #import <OpenGLES/ES2/gl.h>
    #import <OpenGLES/ES2/glext.h>
    #import <GLKit/GLKit.h>

@class OVLScript;
@interface OVLViewController : GLKViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
-(void) loadScript:(OVLScript*)script;
-(void) switchScript:(OVLScript*)script;
-(IBAction) updateCameraPosition:(BOOL)fFront;
-(void) snapshot:(BOOL)sound callback:(void (^)(UIImage* image))callback;
-(IBAction) record;
-(IBAction) resetShader;
-(void) switchFPS:(int32_t)fps;
//+(NSString*) tempFileName:(NSString*)extension;
+(NSString*) tempFilePath:(NSString*)extension;
+(NSString*) didFinishWritingVideo;
+(NSString*) didUpdateDuration; // Every one second while recording
+(NSString*) didRecordFrame; // Every frame while recording
-(BOOL) isReadyToRecord;
@property (nonatomic, retain) NSURL* urlVideo;
@property (nonatomic) BOOL fHD;
@property (nonatomic) BOOL fPhotoRatio; // 4x3 instead of 16x9
@property (nonatomic) BOOL fRecording;
@property (nonatomic) BOOL fFrontCamera;
@property (nonatomic) BOOL fWatermark;
@property (nonatomic) int32_t fps;
@property (nonatomic, readonly) AVCaptureDevice *camera;
@property (nonatomic, readonly) NSInteger duration;
@property (nonatomic) GLuint renderbufferEx; // for external monitor
@property (nonatomic, readonly) EAGLContext* context;
@property (nonatomic) BOOL fProcessAudio;
@property (nonatomic) float speed;
@property (nonatomic) CMTime maxDuration;
@property (nonatomic) BOOL fLandscape;
@property (nonatomic) UIImage* imageTexture;
@property (nonatomic, readonly) GLKView* glkView;
@property (nonatomic) CMTime timeRecorded;
@property (nonatomic) BOOL fNoAudio;
@property (nonatomic, retain) AVAsset* assetSrc;
@property (nonatomic, readonly) AVCaptureSession* session;
@end
