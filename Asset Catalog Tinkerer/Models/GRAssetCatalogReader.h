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
 @method imagesFromBundle:catalogName:
 @abstract Gets all the imagens contained inside an asset catalog
 @param bundle
 The owner of the asset catalog, usually an app bundle
 @param name
 The name of the asset catalog (without the extension), usually "Assets"
 @result An NSArray containing a dictionary for each image, the dictionary has a "name" key (NSString) and an "image" key (NSImage)
 */
+ (NSArray *)imagesFromBundle:(NSBundle *)bundle catalogName:(NSString *)name;

@end
