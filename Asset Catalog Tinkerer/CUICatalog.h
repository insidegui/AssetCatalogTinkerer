//
//  CUICatalog.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/09/15.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CUINamedImage : NSObject

@property (copy, nonatomic) NSString *name;
@property (readonly, nonatomic) int exifOrientation;
@property (readonly, nonatomic) BOOL isStructured;
@property (readonly, nonatomic) NSInteger templateRenderingMode;
@property (readonly, nonatomic) BOOL isTemplate;
@property (readonly, nonatomic) BOOL isVectorBased;
@property (readonly, nonatomic) BOOL hasSliceInformation;
@property (readonly, nonatomic) NSInteger resizingMode;
@property (readonly, nonatomic) int blendMode;
@property (readonly, nonatomic) CGFloat opacity;
@property (readonly, nonatomic) NSInteger imageType;
@property (readonly, nonatomic) CGFloat scale;
@property (readonly, nonatomic) NSSize size;
@property (readonly, nonatomic) CGImageRef image;

@end

@class CUIThemeRendition, CUIRenditionKey;


@interface CUINamedLookup : NSObject

@property(copy, nonatomic) NSString *name;
@property(readonly, nonatomic) BOOL representsOnDemandContent;

- (void)setRepresentsOnDemandContent:(BOOL)onDemand;
- (id)renditionKey;
- (NSString *)renditionName;
- (id)initWithName:(NSString *)name usingRenditionKey:(NSString *)key fromTheme:(unsigned long long)theme;

@end


@interface CUINamedLayerStack : CUINamedLookup

@property(retain, nonatomic) NSArray *layers;
@property(readonly, nonatomic) struct CGImage *radiosityImage;
@property(readonly, nonatomic) struct CGImage *flattenedImage;
@property(readonly, nonatomic) struct CGSize size;

@end


@interface CUICatalog : NSObject

@property (nonatomic, readonly) NSArray *allImageNames;

+ (instancetype)systemUICatalog;
+ (instancetype)defaultUICatalog;

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)outError;
- (CUINamedLayerStack *)layerStackWithName:(NSString *)name;
- (NSArray *)imagesWithName:(NSString *)name;

@end