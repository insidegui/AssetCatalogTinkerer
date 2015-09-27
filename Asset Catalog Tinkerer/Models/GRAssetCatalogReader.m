//
//  GRAssetCatalogReader.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRAssetCatalogReader.h"

#import "CUICatalog.h"

@implementation GRAssetCatalogReader

+ (NSArray *)imagesFromCatalogAtURL:(NSURL *)catalogURL
{
    NSError *catalogError;
    CUICatalog *catalog = [[CUICatalog alloc] initWithURL:catalogURL error:&catalogError];
    
    if (catalogError) {
        NSLog(@"CoreUI error: %@", catalogError);
        return nil;
    }
    
    NSMutableArray *outputImages = [[NSMutableArray alloc] initWithCapacity:catalog.allImageNames.count];
    
    for (NSString *name in catalog.allImageNames) {
        NSArray *images = [catalog imagesWithName:name];
        for (CUINamedImage *namedImage in images) {
            @autoreleasepool {
                [self addImage:namedImage to:outputImages];
            }
        }
    }
    
    return [outputImages copy];
}

+ (void)addImage:(CUINamedImage *)namedImage to:(NSMutableArray *)outputImages
{
    if (namedImage == nil)
        return;

    NSString *filename;
    if (namedImage.scale > 1.0) {
        filename = [NSString stringWithFormat:@"%@@%.0fx.png", namedImage.name, namedImage.scale];
    } else {
        filename = [NSString stringWithFormat:@"%@.png", namedImage.name];
    }
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:namedImage.image];
    imageRep.size = namedImage.size;
    
    NSData *pngData = [imageRep representationUsingType:NSPNGFileType properties:@{NSImageInterlaced:@(NO)}];
    if (!pngData.length) {
        NSLog(@"Unable to get PNG data from image named %@", namedImage.name);
        return;
    }

    NSImage *img = [[NSImage alloc] initWithData:pngData];

    [outputImages addObject:@{
            @"name" : namedImage.name,
            @"image" : img,
            @"filename": filename,
            @"png": pngData
    }];
}

@end
