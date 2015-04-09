//
//  OVLNode.h
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol OVLNodeDelegate <NSObject>
-(BOOL) hasDepth:(GLuint)depth;
-(GLuint) popTexture;
-(GLuint) forkTexture;
-(void) pushTexture:(GLuint)index;
-(void) shiftTexture;
-(void) inheritTexture;
-(void) renderRect;
-(void) prepareFrame;
-(GLfloat) audioVolume;
-(GLfloat) currentTime;
@end

@interface OVLNode : NSObject
+(id) swap;
+(id) shift;
+(id) fork;
+(id) push;
-(void) process:(id <OVLNodeDelegate>)delegate;
-(BOOL) emulate:(NSMutableArray*)stack;
-(NSString*) stringFromAttrs;
-(void) setPixelSize:(const GLfloat*)pv delegate:(id <OVLNodeDelegate>)delegate;
-(void) set2fv:(const GLfloat*)pv forName:(const GLchar*)name;
-(void) compile;
-(void) clearProgram;
-(id) attrForName:(NSString*)name;
-(void) setAttr:(id)value forName:(NSString*)name;
-(void) setDefault;
-(NSDictionary*) jsonObject;
-(NSSet*) hiddenKeys;
-(NSDictionary*) attributes;
-(void) setAttributes:(NSDictionary*)attributes;
-(NSMutableArray*) visibleAttributeKeys;
-(NSArray*) primaryAttributeKeys;
-(BOOL) hasPrimary;
-(BOOL) isPrimeryKey:(NSString*)key;
-(void) addPrimaryKey:(NSString*)key;
-(void) removePrimaryKey:(NSString*)key;
-(void) removeAllPrimaryKeys;
-(void) setOrientation:(UIDeviceOrientation)orientation;

@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSString* shader;
@end
