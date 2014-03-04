//
//  GRAssetCatalogReader.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRAssetCatalogReader : NSObject

/*!
 @method imagesFromBundle:
 @abstract Gets all the imagens contained inside the Assets.car file of the specified bundle
 @result An NSArray containing a dictionary for each image, the dictionary has a "name" key (NSString) and an "image" key (NSImage)
 */
+ (NSArray *)imagesFromBundle:(NSBundle *)bundle catalogName:(NSString *)name;

@end
