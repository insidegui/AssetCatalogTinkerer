//
//  NSImage+BrightnessDetection.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 03/02/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (BrightnessDetection)

- (CGFloat)averageBrightness;

@end
