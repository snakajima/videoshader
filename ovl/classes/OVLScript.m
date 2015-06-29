//
//  OVLScript.m
//  cartoon
//
//  Created by satoshi on 11/7/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLScript.h"
#import "OVLShaderManager.h"
#import "OVLNode.h"
#import "OVLFilter.h"
#import "OVLBlurFilter.h"
#import "OVLBlender.h"
#import "OVLMixer.h"
#import "OVLSource.h"
#import "OVLPlaneShaders.h"
#import "OVLTexture.h"
#import "OVLTexturedFilter.h"

@interface OVLScript() {
    NSMutableDictionary* _script;
}
@end

@implementation OVLScript

+(id) scriptWithScript:(OVLScript*)src nodeCount:(NSUInteger)count {
    OVLScript* script = [[OVLScript alloc] init];
    script->_script = src->_script;
    script.nodes = [NSMutableArray arrayWithArray:src.nodes];
    while(script.nodes.count > count) {
        [script.nodes removeLastObject];
    }
    return script;
}

+(NSString*) pathForImportFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *pathLibrary = [paths objectAtIndex:0];
    NSString *pathImport = [pathLibrary stringByAppendingPathComponent:@"import"];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:pathImport]) {
        NSError *err = nil;
        BOOL success = [manager createDirectoryAtPath:pathImport withIntermediateDirectories:NO attributes:Nil error:&err];
        if (!success) {
            NSLog(@"OVLSc pathForImportFolder error:%@", err);
        }
    }
    return pathImport;
}

+(NSString*) pathForNewImportScript {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'script'YYMMddHHmmss'.vsscript'"];
    NSString* filename = [formatter stringFromDate:[NSDate date]];
    NSString* pathFolder = [OVLScript pathForImportFolder];
    return [pathFolder stringByAppendingPathComponent:filename];
}

+(NSString*) pathForNewScript {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'script'YYMMddHHmmss'.vsscript'"];
    NSString* filename = [formatter stringFromDate:[NSDate date]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathFolder = [paths objectAtIndex:0];
    return [pathFolder stringByAppendingPathComponent:filename];
}

-(id) initWithDictionary:(NSDictionary*)json {
    if (self = [super init]) {
        _script = [NSMutableDictionary dictionaryWithDictionary:json];
        self.nodes = [OVLScript parseScript:_script[@"pipeline"]];
    }
    return self;
}

-(void) compile {
    for (OVLNode* node in self.nodes) {
        [node compile];
    }
}

// Returns the first primerty node
-(OVLNode*) primaryNode {
    for (OVLNode* node in self.nodes) {
        if (node.hasPrimary) {
            return node;
        }
    }
    return nil;
}

+(NSMutableArray*) parseScript:(NSArray*)nodes {
    OVLShaderManager* manager = [OVLShaderManager sharedInstance];
    NSMutableArray* nodeList = [NSMutableArray array];
    for (NSDictionary* node in nodes) {
        NSString* control = node[@"control"];
        NSString* filter = node[@"filter"];
        NSString* blender = node[@"blender"];
        NSString* mixer = node[@"mixer"];
        NSString* source = node[@"source"];
        if (filter || blender || mixer || source) {
            OVLFilter* filterNode;
            if (filter) {
                if ([manager isBlurShader:filter]) {
                    filterNode = [OVLBlurFilter alloc];
                } else if ([manager isTextureShader:filter]) {
                    filterNode = [OVLTexturedFilter alloc];
                } else {
                    filterNode = [OVLFilter alloc];
                }
            } else if (blender) {
                filterNode = [OVLBlender alloc];
                filter = blender;
            } else if (mixer) {
                filterNode = [OVLMixer alloc];
                filter = mixer;
            } else {
                if ([manager isTextureShader:source]) {
                    filterNode = [OVLTexture alloc];
                } else {
                    filterNode = [OVLSource alloc];
                }
                filter = source;
            }
            if ([manager isOrientationShader:filter]) {
                filterNode.fOrientation = YES;
            }
            if ([manager isAudioShader:filter]) {
                filterNode.fAudio = YES;
            }
            NSString* vertex = node[@"vertex"];
            vertex = vertex ? vertex : [manager vertexOfShader:filter];
            if (![filter isKindOfClass:[NSString class]] || !vertex) {
                NSLog(@"OVLSc invalid filter(%@) or vertex(%@", filter, vertex);
                continue;
            }
            
            filterNode = [filterNode initWithVertexShader:vertex fragmentShader:filter];
            filterNode.repeat = ((NSNumber*)node[@"repeat"]).intValue;
            filterNode.fork = (((NSNumber*)node[@"fork"]).boolValue);
            [filterNode setUI:node[@"ui"]];
            [filterNode setExtra:node[@"extra"]];
        
            NSDictionary* attrs = node[@"attr"];
            if (attrs && ![attrs isKindOfClass:[NSDictionary class]]) {
                NSLog(@"OVLSc invalid attrs type (%@)", [attrs class]);
                continue;
            }
            OVLShaderManager* manager = [OVLShaderManager sharedInstance];
            NSDictionary* infos = [manager attrOfShader:filter];
            for (NSString* key in infos.allKeys) {
                id attr = attrs[key];
                if (!attr) {
                    NSDictionary* info = infos[key];
                    attr = info[@"default"];
                }
                [filterNode setAttr:attr forName:key];
            }
            // DEBUG
            for (NSString* key in attrs.allKeys) {
                if (!infos[key]) {
                    NSLog(@"OVLSc MISSING DEFAULT %@ for %@", key, filter);
                }
            }

            [nodeList addObject:filterNode];
        } else if ([control isEqualToString:@"fork"]) {
            [nodeList addObject:[OVLNode fork]];
        } else if ([control isEqualToString:@"swap"]) {
            [nodeList addObject:[OVLNode swap]];
        } else if ([control isEqualToString:@"shift"]) {
            [nodeList addObject:[OVLNode shift]];
        } else if ([control isEqualToString:@"previous"]) {
            [nodeList addObject:[OVLNode push]];
        }
    }
    return nodeList;
}

-(NSArray*) _jsonArray {
    NSMutableArray* array = [NSMutableArray array];
    for (OVLNode* node in _nodes) {
        [array addObject:node.jsonObject];
    }
    return array;
}

-(void) setOrientation:(UIDeviceOrientation)orientation {
    for (OVLNode* node in _nodes) {
        [node setOrientation:orientation];
    }
}

-(void) _update {
    //NSMutableDictionary* script = [NSMutableDictionary dictionaryWithDictionary:_script];
    _script[@"pipeline"] = [self _jsonArray];
    //_script = script;
}

-(void) setTitle:(NSString*)title {
    _script[@"title"] = title;
}

-(void) saveToPath:(NSString*)path {
    [self _update];
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:_script options:NSJSONWritingPrettyPrinted error:&error];
    [data writeToFile:path atomically:YES];
    
    OVLShaderManager* manager = [OVLShaderManager sharedInstance];
    [manager discardThumbnailAtPath:path];
}

-(NSString*) serializedString {
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:_script options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(UIImage*) processImage:(UIImage*)imageSrc context:(EAGLContext*)context size:(CGSize)size {
    //NSLog(@"OS processImage called");
    if (_nodes.count == 0) {
        return imageSrc;
    }
    
    [self compile];
    /*
    NSDictionary* extra = @{
        @"pipeline":@[
            @{ @"filter":@"simple", @"vertex":@"rotation_left" },
            @{ @"filter":@"simple", @"vertex":@"rotation_right" },
        ]
    };
    OVLScript* scriptExtra = [[OVLScript alloc] initWithDictionary:extra];
    [scriptExtra compile];

    NSMutableArray* nodes = [NSMutableArray arrayWithObject:scriptExtra.nodes[0]];
    [nodes addObjectsFromArray:self.nodes];
    [nodes addObject:scriptExtra.nodes[1]];
    */
    glGetError(); // HACK: dummy call to reset the OpenGL

    OVLPlaneShaders* shader = [[OVLPlaneShaders alloc] initWithSize:size withNodeList:self.nodes viewSize:imageSrc.size landscape:NO];
    
    NSError* err = nil;
    GLKTextureInfo* textureSrc = [GLKTextureLoader textureWithCGImage:imageSrc.CGImage options:nil error:&err];
    if (err) {
        NSLog(@"OVLSc textureOrg %@", err);
    }
    [shader setSourceTexture:textureSrc.name];
  
    // Set the initial projection to all the shaders
    GLKMatrix4 matrix = GLKMatrix4MakeOrtho(0.0, 1.0, 1.0, 0.0, 1.0, 100.0);
    [shader setProjection:&matrix];

    [shader process];
    glFlush();

    UIImage* imageOrg = [shader snapshot:NO];
    UIImage* image = [UIImage imageWithCGImage:imageOrg.CGImage scale:imageSrc.scale orientation:imageSrc.imageOrientation];
    return image;
}

-(UIImage*) generateThumb256 {
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context || ![EAGLContext setCurrentContext:context]) {
        NSLog(@"OVLSc Failed to initialize or set current OpenGL context");
        return nil;
    }
    UIImage* imageBefore = [UIImage imageNamed:@"Lenna256.tiff"];
    UIImage* imageAfter = [self processImage:imageBefore context:context size:imageBefore.size];
    [EAGLContext setCurrentContext:nil];
    return imageAfter;
}


@end
