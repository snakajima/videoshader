//
//  ShaderManager.h
//  cartoon
//
//  Created by satoshi on 11/3/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OVLScript;
@interface OVLShaderManager : NSObject
+(id) sharedInstance;
-(NSString*) titleOfShader:(NSString*)key;
-(NSString*) descriptionOfShader:(NSString*)key;
-(NSString*) vertexOfShader:(NSString*)key;
-(NSDictionary*) attrOfShader:(NSString*)key;
-(NSString*) typeOfShader:(NSString*)key;
-(UIImage*) imageForStack:(NSArray*)stack;
-(NSString*) titleOfUserScript:(NSString*)path;
-(NSUInteger) typeCount;
-(NSString*) keyOfTypeIndex:(NSUInteger)index;
-(NSString*) titleOfTypeIndex:(NSUInteger)index;
-(NSUInteger) numberOfShadersForTypeIndex:(NSUInteger)index;
-(NSString*) shaderAtIndexPath:(NSIndexPath*)indexPath;
-(NSArray*) typeIndexTitles;
-(BOOL) isBlurShader:(NSString*)key;
-(BOOL) isTextureShader:(NSString*)key;
-(BOOL) isOrientationShader:(NSString*)key;
-(BOOL) isAudioShader:(NSString*)key;
-(UIImage*) thumbnailForScriptAtPath:(NSString*)path withImage:(UIImage*)imageThumb;
-(void) discardThumbnailAtPath:(NSString*)path;
-(void) saveMovieToPhotoAlbumAsync:(NSURL*)url callback:(void (^)(NSURL *assetURL))callback;
-(UIImage*) processImage:(UIImage*)imageBefore withScript:(OVLScript*)script size:(CGSize)size orientation:(UIDeviceOrientation)orientation;
-(UIImage*) processImage:(UIImage*)imageBefore withScriptAtPath:(NSString*)path size:(CGSize)size orientation:(UIDeviceOrientation)orientation;
@property (nonatomic, retain) OVLScript* scriptUnsaved;
@property (nonatomic, retain) NSURL* urlLaunched;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, readonly) UIImage* thumbnail;
@end
