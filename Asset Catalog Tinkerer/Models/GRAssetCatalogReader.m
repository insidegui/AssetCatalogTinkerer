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
        CUINamedImage *namedImage = [catalog imageWithName:rendition scaleFactor:2.0];
        NSImage *img = [[NSImage alloc] initWithCGImage:namedImage.image size:namedImage.size];
        
        [outputImages addObject:@{@"name": namedImage.name, @"image": img}];
    }
    
    return [outputImages copy];
}

@end
