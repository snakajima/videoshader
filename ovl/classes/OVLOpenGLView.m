//
//  OVLOpenGLView.m
//  cartoon
//
//  Created by satoshi on 1/21/14.
//  Copyright (c) 2014 satoshi. All rights reserved.
//

#import "OVLOpenGLView.h"

@implementation OVLOpenGLView
@dynamic glLayer;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(CAEAGLLayer*) glLayer {
    return (CAEAGLLayer *)self.layer;
}
@end
