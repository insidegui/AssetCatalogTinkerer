//
//  AssetCatalogReader.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@interface AssetCatalogReader : NSObject

@property (nonatomic, assign) NSSize thumbnailSize;

@property (nonatomic, strong) NSArray <NSDictionary <NSString *, NSObject *> *> *__nonnull images;
@property (nonatomic, copy) NSString *__nullable catalogName;
@property (nonatomic, copy) NSError *__nullable error;

- (instancetype __nonnull)initWithFileURL:(NSURL * __nonnull)URL;
- (void)readWithCompletionHandler:(void (^__nonnull)())callback progressHandler:(void (^__nullable)(double progress))progressCallback;

- (void)cancelReading;

@end
