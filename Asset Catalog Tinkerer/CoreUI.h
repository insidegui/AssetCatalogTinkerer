//
//  CoreUI.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 03/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CUICommonAssetStorage : NSObject

- (CUICommonAssetStorage *)initWithPath:(NSString *)path;

- (NSArray *)allAssetKeys;
- (NSArray *)allRenditionNames;

- (BOOL)assetExistsForKey:(id)arg1;
- (id)assetForKey:(id)key;


@end

@interface CUIStructuredThemeStore : NSObject

- (CUICommonAssetStorage *)themeStore;

@end

@interface CUICatalog : NSObject

+ (id)defaultUICatalogForBundle:(NSBundle *)bundle;
+ (id)systemUICatalog;
+ (id)defaultUICatalog;

- (id)initWithName:(NSString *)carFileName fromBundle:(id)arg2 error:(NSError **)outError;
- (id)initWithName:(NSString *)carFileName fromBundle:(id)arg2;

- (id)imageWithName:(NSString *)name scaleFactor:(double)factor deviceIdiom:(NSInteger)idiom deviceSubtype:(NSUInteger)subtype;
- (id)imageWithName:(NSString *)name scaleFactor:(double)factor deviceIdiom:(NSInteger)idiom;
- (id)imageWithName:(NSString *)name scaleFactor:(double)factor;

- (id)_themeStore;

@end

@interface CUINamedImage : NSObject

@property(copy, nonatomic) NSString *name;
@property(readonly, nonatomic) BOOL hasSliceInformation;
@property(readonly, nonatomic) long long resizingMode;
@property(readonly, nonatomic) int blendMode;
@property(readonly, nonatomic) double opacity;
@property(readonly, nonatomic) double scale;
@property(readonly, nonatomic) NSSize size;
@property(readonly, nonatomic) CGImageRef image;

- (id)initWithName:(id)arg1 usingRenditionKey:(id)arg2 fromTheme:(unsigned long long)arg3;

@end

@interface CUIRenditionKey : NSObject <NSCopying, NSCoding>

- (id)nameOfAttributeName:(int)arg1;
- (id)description;
- (long long)themeIdentifier;
- (void)setThemeIdentifier:(long long)arg1;
- (long long)themeSubtype;
- (void)setThemeSubtype:(long long)arg1;
- (long long)themeIdiom;
- (void)setThemeIdiom:(long long)arg1;
- (long long)themeScale;
- (void)setThemeScale:(long long)arg1;
- (long long)themeLayer;
- (void)setThemeLayer:(long long)arg1;
- (long long)themePresentationState;
- (void)setThemePresentationState:(long long)arg1;
- (long long)themeState;
- (void)setThemeState:(long long)arg1;
- (long long)themeDimension2;
- (void)setThemeDimension2:(long long)arg1;
- (long long)themeDimension1;
- (void)setThemeDimension1:(long long)arg1;
- (long long)themeValue;
- (void)setThemeValue:(long long)arg1;
- (long long)themeDirection;
- (void)setThemeDirection:(long long)arg1;
- (long long)themeSize;
- (void)setThemeSize:(long long)arg1;
- (long long)themePart;
- (void)setThemePart:(long long)arg1;
- (long long)themeElement;
- (void)setThemeElement:(long long)arg1;
- (id)initWithThemeElement:(long long)arg1 themePart:(long long)arg2 themeSize:(long long)arg3 themeDirection:(long long)arg4 themeValue:(long long)arg5 themeDimension1:(long long)arg6 themeDimension2:(long long)arg7 themeState:(long long)arg8 themePresentationState:(long long)arg9 themeLayer:(long long)arg10 themeScale:(long long)arg11 themeIdentifier:(long long)arg12;
- (const struct _renditionkeytoken *)keyList;
- (void)removeValueForKeyTokenIdentifier:(long long)arg1;
- (void)copyValuesFromKeyList:(const struct _renditionkeytoken *)arg1;
- (void)setValuesFromKeyList:(const struct _renditionkeytoken *)arg1;
- (void)dealloc;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithKeyList:(const struct _renditionkeytoken *)arg1;
- (id)init;
- (void)_expandKeyIfNecessaryForCount:(long long)arg1;
- (unsigned short)_systemTokenCount;

@end