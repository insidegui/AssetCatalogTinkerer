//
//  AssetCatalogReader.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "AssetCatalogReader.h"

#import "CUICatalog.h"
#import "CoreUI+TV.h"

NSString * const kAssetCatalogReaderErrorDomain = @"br.com.guilhermerambo.AssetCatalogReader";

@interface AssetCatalogReader ()

@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic, strong) CUICatalog *catalog;
@property (nonatomic, strong) NSMutableArray <NSDictionary <NSString *, NSObject *> *> *mutableImages;
@property (nonatomic, assign) BOOL cancelled;

@end

@implementation AssetCatalogReader

- (instancetype)initWithFileURL:(NSURL *)URL
{
    self = [super init];
    
    _fileURL = [URL copy];
    
    return self;
}

- (NSMutableArray <NSDictionary <NSString *, NSObject *> *> *)mutableImages
{
    if (!_mutableImages) _mutableImages = [NSMutableArray new];
    
    return _mutableImages;
}

- (NSArray <NSDictionary <NSString *, NSObject *> *> *)images
{
    return [self.mutableImages copy];
}

- (void)cancelReading
{
    self.cancelled = true;
}

- (void)readWithCompletionHandler:(void (^__nonnull)())callback progressHandler:(void (^__nullable)(double progress))progressCallback
{
    __block uint64 totalItemCount = 0;
    __block uint64 loadedItemCount = 0;
    
    NSString *catalogPath = nil;
    
    // we need to figure out if the user selected an app bundle or a specific .car file
    NSBundle *bundle = [NSBundle bundleWithURL:self.fileURL];
    if (!bundle) {
        catalogPath = self.fileURL.path;
        self.catalogName = catalogPath.lastPathComponent;
    } else {
        catalogPath = [bundle pathForResource:@"Assets" ofType:@"car"];
        self.catalogName = [NSString stringWithFormat:@"%@ | %@", bundle.bundlePath.lastPathComponent, catalogPath.lastPathComponent];
    }
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // bundle is nil for some reason
        if (!catalogPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.error = [NSError errorWithDomain:kAssetCatalogReaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Unable to find asset catalog path"}];
                callback();
            });
            
            return;
        }
        
        NSError *catalogError;
        self.catalog = [[CUICatalog alloc] initWithURL:[NSURL fileURLWithPath:catalogPath] error:&catalogError];
        if (catalogError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.error = catalogError;
                callback();
            });
            
            return;
        }
        
        if (!self.catalog.allImageNames.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.error = [NSError errorWithDomain:kAssetCatalogReaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"The asset catalog contains no images"}];
                callback();
            });
            
            return;
        }
        
        totalItemCount = self.catalog.allImageNames.count;
        
        for (NSString *imageName in self.catalog.allImageNames) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                double loadedFraction = (double)loadedItemCount / (double)totalItemCount;
                if (progressCallback) progressCallback(loadedFraction);
            });
            
            for (CUINamedImage *namedImage in [self.catalog imagesWithName:imageName]) {
                if (self.cancelled) return;
                
                @autoreleasepool {
                    if (namedImage == nil) {
                        loadedItemCount++;
                        continue;
                    }
                    
                    NSString *filename;
                    CGImageRef image;
                    
                    if ([namedImage isKindOfClass:[CUINamedLayerStack class]]) {
                        CUINamedLayerStack *stack = (CUINamedLayerStack *)namedImage;
                        if (!stack.layers.count) {
                            loadedItemCount++;
                            continue;
                        }
                        
                        filename = [NSString stringWithFormat:@"%@.png", namedImage.name];
                        image = stack.flattenedImage;
                    } else {
                        if (namedImage.scale > 1.0) {
                            filename = [NSString stringWithFormat:@"%@@%.0fx.png", namedImage.name, namedImage.scale];
                        } else {
                            filename = [NSString stringWithFormat:@"%@.png", namedImage.name];
                        }
                        image = namedImage.image;
                    }
                    
                    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:image];
                    imageRep.size = namedImage.size;
                    
                    NSData *pngData = [imageRep representationUsingType:NSPNGFileType properties:@{NSImageInterlaced:@(NO)}];
                    if (!pngData.length) {
                        NSLog(@"Unable to get PNG data from image named %@", namedImage.name);
                        loadedItemCount++;
                        continue;
                    }
                    
                    NSImage *originalImage = [[NSImage alloc] initWithData:pngData];
                    NSImage *thumbnail = [self constrainImage:originalImage toSize:self.thumbnailSize];
                    
                    [self.mutableImages addObject:@{
                                             @"name" : namedImage.name,
                                             @"image" : originalImage,
                                             @"thumbnail": thumbnail,
                                             @"filename": filename,
                                             @"png": pngData
                                             }];
                    
                    if (self.cancelled) return;
                    
                    loadedItemCount++;
                }
            }
        }
        
        // we've got no images for some reason (the console will usually contain some information from CoreUI as to why)
        if (!self.images.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.error = [NSError errorWithDomain:kAssetCatalogReaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Failed to load images"}];
                callback();
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback();
        });
    });
}

- (NSImage *)constrainImage:(NSImage *)image toSize:(NSSize)size
{
    if (image.size.width <= size.width && image.size.height <= size.height) return [image copy];
    
    CGFloat newWidth, newHeight = 0;
    double rw = image.size.width / size.width;
    double rh = image.size.height / size.height;
    
    if (rw > rh)
    {
        newHeight = MAX(roundl(image.size.height / rw), 1);
        newWidth = size.width;
    }
    else
    {
        newWidth = MAX(roundl(image.size.width / rh), 1);
        newHeight = size.height;
    }
    
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(newWidth, newHeight)];
    [newImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, newWidth, newHeight) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [newImage unlockFocus];
    
    return newImage;
}

@end
