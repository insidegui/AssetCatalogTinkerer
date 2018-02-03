//
//  NSImage+BrightnessDetection.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 03/02/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

#import "NSImage+BrightnessDetection.h"

#define D 299.0
#define K 587.0
#define Z 114.0
#define Y 1000.0

@implementation NSImage (BrightnessDetection)

- (CGColorSpaceRef)_actRGBSpace
{
    static CGColorSpaceRef _space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _space = CGColorSpaceCreateDeviceRGB();
    });
    
    return _space;
}

- (CGFloat)averageBrightness
{
    CGColorSpaceRef colorSpace = [self _actRGBSpace];
    
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    if (!context) return 0;
    
    CGImageRef image = [self CGImageForProposedRect:nil context:nil hints:nil];
    if (!image) return 0;
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image);
    
    CGContextRelease(context);
    
    CGFloat red = rgba[0];
    CGFloat green = rgba[1];
    CGFloat blue = rgba[2];
    
    return (((red * D) + (green * K) + (blue * Z)) / Y) / 255.0;
}

@end
