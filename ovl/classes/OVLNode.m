//
//  OVLNode.m
//  cartoon
//
//  Created by satoshi on 10/27/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLNode.h"
#import "OVLSwap.h"
#import "OVLFork.h"
#import "OVLShift.h"
#import "OVLPrev.h"
#import "OVLShaderManager.h"

@implementation OVLNode
@dynamic shader;

+(id) swap {
    return [[OVLSwap alloc] init];
}

+(id) shift {
    return [[OVLShift alloc] init];
}

+(id) fork {
    return [[OVLFork alloc] init];
}

+(id) push {
    return [[OVLPrev alloc] init];
}

-(void) process:(id <OVLNodeDelegate>)delegate {
    // To be implemented by subclasses
}

-(NSString*) nodeKey {
    return @"N/A";
}

-(NSString*) title {
    OVLShaderManager* manager = [OVLShaderManager sharedInstance];
    return [manager titleOfShader:self.nodeKey];
}

-(BOOL) emulate:(NSMutableArray*)stack {
    return NO;
}

-(NSString*) stringFromAttrs {
    return @"";
}

-(void) setPixelSize:(const GLfloat*)pv delegate:(id <OVLNodeDelegate>)delegate {
    [self set2fv:pv forName:"uPixel"];
}

-(void) set2fv:(const GLfloat*)pv forName:(const GLchar*)name {
    // No operation
}

-(void) compile {
}

-(void) clearProgram {
}

-(NSString*) shader {
    return nil;
}

-(id) attrForName:(NSString*)name {
    return nil;
}

-(void) setAttr:(id)value forName:(NSString*)name {
}

-(void) setDefault {
}

-(NSDictionary*) jsonObject {
    return nil;
}

-(NSSet*) hiddenKeys {
    return nil;
}

-(NSDictionary*) attributes {
    return nil;
}

-(void) setAttributes:(NSDictionary*)attributes {
}

-(BOOL) hasPrimary {
    return NO; 
}

-(BOOL) isPrimeryKey:(NSString*)key {
    return NO;
}

-(void) addPrimaryKey:(NSString*)key {
}

-(void) removePrimaryKey:(NSString*)key {
}

-(void) removeAllPrimaryKeys {
}

-(void) setOrientation:(UIDeviceOrientation)orientation {
}

-(NSMutableArray*) visibleAttributeKeys {
    OVLShaderManager* manager = [OVLShaderManager sharedInstance];
    NSDictionary* attrs = [manager attrOfShader:self.shader];
    NSMutableArray* keys = [NSMutableArray array];
    NSSet* set = [self hiddenKeys];
    for (NSString* key in attrs.allKeys) {
        if (![set containsObject:key]) {
            [keys addObject:key];
        }
    }
    return keys;
}

-(NSArray*) primaryAttributeKeys {
    return nil;
}
@end
