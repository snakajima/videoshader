//
//  OVLShaderManager.m
//  cartoon
//
//  Created by satoshi on 11/3/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OVLShaderManager.h"
#import "OVLScript.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString* s_keys[] = {
    @"control", @"source", @"blender", @"mixer", @"filter"
};

static NSString* s_titles[] = {
    @"Controller", @"Source", @"Blender", @"Mixer", @"Filter"
};

@interface OVLShaderManager () {
    NSDictionary* _shaders;
    NSDictionary* _titles;
    NSMutableDictionary* _grouped;
    NSMutableDictionary* _images;
    NSMutableDictionary* _sorted;
    // Thumbnails
    NSMutableDictionary* _imageCache;
    UIImage* _imageBefore;
}
@end

@implementation OVLShaderManager
@dynamic thumbnail;

+(id) sharedInstance {
    static OVLShaderManager* s_manager = nil;
    if (!s_manager) {
        s_manager = [[OVLShaderManager alloc] init];
    }
    return s_manager;
}

-(NSArray*) typeIndexTitles {
    static NSString* s_s = @"　　●　　";
    return @[s_s, s_titles[0], s_s, s_s, s_titles[1], s_s, s_s, s_titles[2], s_s, s_s, s_titles[3], s_s, s_s, s_titles[4], s_s];
}

-(NSUInteger) typeCount {
    return 5;
}

-(NSString*) keyOfTypeIndex:(NSUInteger)index {
    return s_keys[index];
}

-(NSString*) titleOfTypeIndex:(NSUInteger)index {
    return s_titles[index];
}

-(id) init {
    if (self = [super init]) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"shaders" ofType:@"js"];
        NSError* error = nil;
        _shaders = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"OVLSM error loading script:%@", error);
        }
        _images = [NSMutableDictionary dictionary];
        
        // Create a look-up table from type
        _grouped = [NSMutableDictionary dictionary];
        for (NSString* key in _shaders.allKeys) {
            NSDictionary* item = _shaders[key];
            NSString* type = item[@"type"];
            NSAssert(type!=nil, @"missing type %@", key);
            NSMutableDictionary* items = _grouped[type];
            if (!items) {
                items = [NSMutableDictionary dictionary];
                _grouped[type] = items;
            }
            NSNumber* num = item[@"hidden"];
            if (!num.boolValue) {
                [items setValue:item forKey:key];
            }
        }
        _sorted = [NSMutableDictionary dictionary];
        for (NSString* key in _grouped.allKeys) {
            NSDictionary* items = _grouped[key];
            NSArray* keys = items.allKeys;
            _sorted[key] = [keys sortedArrayUsingComparator:^NSComparisonResult(id key1, id key2) {
                NSDictionary* item1 = items[key1];
                NSDictionary* item2 = items[key2];
                return [item1[@"title"] compare:item2[@"title"]];
            }];
        }
        
        _imageCache = [NSMutableDictionary dictionary];
        _imageBefore = [UIImage imageNamed:@"photo_normal@2x.png"];
    }
    return self;
}

-(UIImage*) thumbnail {
    return _imageBefore;
}

-(NSUInteger) numberOfShadersForTypeIndex:(NSUInteger)index {
    //NSDictionary* items = _grouped[s_keys[index]];
    //return items.allKeys.count;
    NSArray* keys = _sorted[s_keys[index]];
    return keys.count;
}

-(NSString*) shaderAtIndexPath:(NSIndexPath*)indexPath {
    //NSDictionary* items = _grouped[s_keys[indexPath.section]];
    //return items.allKeys[indexPath.row];
    NSArray* keys = _sorted[s_keys[indexPath.section]];
    return keys[indexPath.row];
}

-(NSString*) titleOfShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    return script ? script[@"title"] : key;
}

-(NSString*) descriptionOfShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    return script ? script[@"description"] : @"N/A";
}

-(NSString*) typeOfShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    return script[@"type"];
}

-(BOOL) isOrientationShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    NSNumber* num = script[@"orientation"];
    return num.boolValue;
}

-(BOOL) isBlurShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    NSNumber* num = script[@"blur"];
    return num.boolValue;
}

-(BOOL) isAudioShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    NSNumber* num = script[@"audio"];
    return num.boolValue;
}

-(BOOL) isTextureShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    NSNumber* num = script[@"texture"];
    return num.boolValue;
}

-(NSString*) vertexOfShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    NSString* vertex = script[@"vertex"];
    return vertex ? vertex : @"simple";
}

-(NSDictionary*) attrOfShader:(NSString*)key {
    NSDictionary* script = _shaders[key];
    return script[@"attr"];
}



#define COL_W 10.0
#define CELL_H 50.0
#define CELL_H2 25.0
#define CELL_W 70.0
#define NODE_R 5.0
#define NODE_D 10.0
#define CUR_VY 20.0

void _drawLine(CGContextRef ctx, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat dy1, CGFloat dy2) {
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x1, y1);
    CGContextAddCurveToPoint(ctx, x1, y1 + dy1, x2, y2 - dy2, x2, y2);
    CGContextStrokePath(ctx);
}

-(UIImage*) imageForStack:(NSArray*)stack {
    NSString* key = @"";
    for (NSString* item in stack) {
        key = [NSString stringWithFormat:@"%@%@", key, item];
    }
    UIImage* image = [_images valueForKey:key];
    if (!image) {
        CGRect rc = { 0.0, 0.0, CELL_W, CELL_H };
        UIGraphicsBeginImageContext(rc.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, rc);
        [[UIColor whiteColor] setFill];
        if (stack.count==0) {
            [[UIColor redColor] setFill]; // indicating error (stack underflow)
        }
        [[UIColor colorWithRed:79.0/255.0 green:134.0/255.0 blue:186.0/255.0 alpha:1.0] setStroke];
        CGContextSetLineWidth(ctx, 2.0);
        NSString* item = stack.count > 0 ? stack[stack.count-1] : nil;
        BOOL fSwap = [item isEqualToString:@"X"];
        BOOL fShift = [item isEqualToString:@"H"];
        for (int i=0; i<stack.count; i++) {
            BOOL fLastItem = (i == stack.count-1);
            BOOL fDrawLine = YES;
            BOOL fDrawNode = NO;
            CGFloat x = NODE_R + 1.0 + i * COL_W;
            if (fSwap) {
                if (fLastItem) {
                    _drawLine(ctx, x, 0.0, x - COL_W, CELL_H, CUR_VY, CUR_VY);
                    fDrawLine = NO;
                } else if (i == stack.count-2) {
                    _drawLine(ctx, x, 0.0, x + COL_W, CELL_H, CUR_VY, CUR_VY);
                    fDrawLine = NO;
                }
            }
            if (fLastItem) {
                if ([item isEqualToString:@"Y"]) {
                    _drawLine(ctx, x - COL_W, CELL_H2, x, CELL_H, 0.0, CUR_VY);
                    CGRect rc = { x - COL_W - 2.0, CELL_H2 - 2.0, 4.0, 4.0 };
                    CGContextBeginPath(ctx);
                    CGContextAddEllipseInRect(ctx, rc);
                    CGContextClosePath(ctx);
                    CGContextStrokePath(ctx);
                    fDrawLine = NO;
                } else if ([item isEqualToString:@"S"]) {
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, x, CELL_H2);
                    CGContextAddLineToPoint(ctx, x, CELL_H);
                    CGContextStrokePath(ctx);
                    fDrawNode = YES;
                    fDrawLine = NO;
                } else if (fShift) {
                    _drawLine(ctx, x, 0.0, x - i * COL_W, CELL_H, CUR_VY, CUR_VY);
                    fDrawLine = NO;
                }
            } else {
                if (fShift) {
                    _drawLine(ctx, x, 0.0, x + COL_W, CELL_H, CUR_VY, CUR_VY);
                    fDrawLine = NO;
                }
            }
            if (fDrawLine) {
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, x, 0.0);
                CGContextAddLineToPoint(ctx, x, CELL_H);
                CGContextStrokePath(ctx);
            }
            if (fLastItem) {
                fDrawNode |= [item isEqualToString:@"F"];
                BOOL fDrawBlend = [item isEqualToString:@"B"];
                if ([item isEqualToString:@"M"]) {
                    _drawLine(ctx, x + COL_W * 2.0, 0.0, x, CELL_H2, CUR_VY, 0.0);
                    fDrawBlend = YES;
                }
                if (fDrawBlend) {
                    _drawLine(ctx, x + COL_W, 0.0, x, CELL_H2, CUR_VY, 0.0);
                    fDrawNode = YES;
                }
                if (fDrawNode) {
                    CGRect rc = { x - NODE_R, CELL_H2 - NODE_R, NODE_D, NODE_D };
                    CGContextBeginPath(ctx);
                    CGContextAddEllipseInRect(ctx, rc);
                    CGContextClosePath(ctx);
                    CGContextDrawPath(ctx, kCGPathFillStroke);
                }
            }
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        [_images setValue:image forKey:key];
        UIGraphicsEndImageContext();
    }
    return image;
}

-(NSString*) titleOfUserScript:(NSString*)path {
    NSString* title = _titles[path];
    if (!title) {
        NSError* error = nil;
        NSDictionary* script = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:&error];
        if (script) {
            title = script[@"title"];
            if (!title) {
                title = path.lastPathComponent;
            }
        } else {
            title = [NSString stringWithFormat:@"Invalid Script (%@)", path.lastPathComponent];
        }
    }
    return title;
}

-(void) discardThumbnailAtPath:(NSString*)path {
    [_imageCache removeObjectForKey:path];
}

-(UIImage*) processImage:(UIImage*)imageBefore withScript:(OVLScript*)script size:(CGSize)size orientation:(UIDeviceOrientation)orientation {
    UIImage* image = nil;
    [script setOrientation:orientation];
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context || ![EAGLContext setCurrentContext:context]) {
        NSLog(@"OVLSM Failed to initialize or set current OpenGL context");
    } else {
        image = [script processImage:imageBefore context:context size:size];
        [EAGLContext setCurrentContext:nil];
    }
    
    return image;
}

-(UIImage*) processImage:(UIImage*)imageBefore withScriptAtPath:(NSString*)path size:(CGSize)size orientation:(UIDeviceOrientation)orientation {
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"OVLSM error loading script:%@ at %@", error, path);
        return nil;
    }

    OVLScript* script = [[OVLScript alloc] initWithDictionary:json];
    return [self processImage:imageBefore withScript:script size:size orientation:orientation];
}

// imageThumb is optional, and it won't be cached if specified.
-(UIImage*) thumbnailForScriptAtPath:(NSString*)path withImage:(UIImage*)imageThumb {
    UIImage* image = nil;
    NSData* data = imageThumb ? nil : [_imageCache valueForKey:path];
    if (data) {
        image = [UIImage imageWithData:data];
    }
    if (!image) {
        UIImage* imageBefore = imageThumb ? imageThumb : _imageBefore;
        image = [self processImage:imageBefore withScriptAtPath:path size:imageBefore.size orientation:UIDeviceOrientationLandscapeLeft];

        if (!imageThumb) {
            data = UIImageJPEGRepresentation(image, 0.1);
            [_imageCache setValue:data forKey:path];
        }
    }
    return image;
}

-(void) saveMovieToPhotoAlbumAsync:(NSURL*)url callback:(void (^)(NSURL *assetURL))callback {
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mQueue = dispatch_get_main_queue();
    dispatch_async(aQueue, ^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_async(mQueue, ^{
                NSLog(@"OVLSM didFinishWritingMovie complete");
                callback(assetURL);
            });
        }];
    });
}
@end
