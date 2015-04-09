//
//  OVLScript.h
//  cartoon
//
//  Created by satoshi on 11/7/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class OVLNode;
@interface OVLScript : NSObject
@property (nonatomic, retain) NSMutableArray* nodes;
@property (nonatomic, retain) UIImage* imageThumb;
-(id) initWithDictionary:(NSDictionary*)json;
-(void) compile;
-(void) saveToPath:(NSString*)path;
-(void) setTitle:(NSString*)title;
-(UIImage*) processImage:(UIImage*)imageSrc context:(EAGLContext*)context size:(CGSize)size;
-(OVLNode*) primaryNode;
-(NSString*) serializedString;
+(id) scriptWithScript:(OVLScript*)src nodeCount:(NSUInteger)count;
+(NSString*) pathForNewScript;
+(NSString*) pathForImportFolder;
+(NSString*) pathForNewImportScript;
-(UIImage*) generateThumb256;
-(void) setOrientation:(UIDeviceOrientation)orientation;
@end
