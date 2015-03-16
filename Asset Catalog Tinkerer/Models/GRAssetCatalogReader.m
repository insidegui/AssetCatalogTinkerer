//
//  GRAssetCatalogReader.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRAssetCatalogReader.h"

#import "CoreUI.h"

@implementation GRAssetCatalogReader

+ (NSArray *)imagesFromBundle:(NSBundle *)bundle catalogName:(NSString *)name
{
    if (!bundle) return @[];
    
    // initializes the CUICatalog for the specified bundle
    CUICatalog *catalog = [[CUICatalog alloc] initWithName:name fromBundle:bundle];
    
    NSArray *renditionNames = [[[catalog _themeStore] themeStore] allRenditionNames];
    
    // prepare output
    NSMutableArray *outputImages = [[NSMutableArray alloc] initWithCapacity:renditionNames.count];
    
    // gets all the images from the catalog and stores them inside a dictionary inside the output array
    for (NSString *rendition in renditionNames) {
        CGImageRef idiom0image = NULL;
        for (NSUInteger idiom = 0; idiom < 10; idiom++) {
            // images with idiom 0 (universal) will be returned also for other idioms
            // store image with idiom 0 and add only images that differs
            CUINamedImage *image = [catalog imageWithName:rendition scaleFactor:2.0 deviceIdiom:idiom];

            if (idiom == 0)
                idiom0image = image.image;
            else if (idiom0image == image.image)
                continue;

            [self addImage:image withIdiom:idiom to:outputImages];
        }
    }
    
    return [outputImages copy];
}

+ (NSString *)lookupIdiom:(NSUInteger)idiom
{
    switch (idiom) {
        case 0:
            return @"universal";
        case 1:
            return @"iphone";
        case 2:
            return @"ipad";
        default:
            return [@(idiom) stringValue];
    }
}

+ (void)addImage:(CUINamedImage *)namedImage withIdiom:(NSUInteger)idiom to:(NSMutableArray *)outputImages
{
    if (namedImage == nil)
        return;

    NSImage *img = [[NSImage alloc] initWithCGImage:namedImage.image size:namedImage.size];

    [outputImages addObject:@{
            @"name" : idiom == 0 ? namedImage.name : [NSString stringWithFormat:@"%@~%@", namedImage.name, [self lookupIdiom:idiom]],
            @"image" : img
    }];
}

@end
