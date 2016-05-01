//
//  CoreUI.h
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

#define kCoreThemePresentationStateActive 0
#define kCoreThemePresentationStateInactive 1
#define kCoreThemePresentationStateActiveMain 2

NSString *presentationStateNameForPresentationState(long long state) {
    switch (state) {
        case kCoreThemePresentationStateActive:
            return @"Active";
            break;
        case kCoreThemePresentationStateInactive:
            return @"Inactive";
            break;
        case kCoreThemePresentationStateActiveMain:
            return @"ActiveMain";
            break;
    }
    
    return nil;
}

struct _renditionkeytoken {
    unsigned short identifier;
    unsigned short value;
};

@interface CUIRenditionKey: NSObject

@property (readonly) struct _renditionkeytoken *keyList;

@property (readonly) long long themeScale;
@property (readonly) long long themeState;
@property (readonly) long long themeDirection;
@property (readonly) long long themeSize;
@property (readonly) long long themeElement;
@property (readonly) long long themePart;

@end

@interface CUIThemeRendition: NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) CGImageRef unslicedImage;

@end

@interface CUICommonAssetStorage: NSObject

@property (readonly) NSArray <CUIRenditionKey *> *allAssetKeys;

@end

@interface CUIStructuredThemeStore : NSObject

- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithPath:(NSString *)path;
- (NSData *)lookupAssetForKey:(struct _renditionkeytoken *)key;
- (CUIThemeRendition *)renditionWithKey:(const struct _renditionkeytoken *)key;

@property (readonly) CUICommonAssetStorage *themeStore;

@end

@interface CUICatalog : NSObject

+ (instancetype)systemUICatalog;
+ (instancetype)defaultUICatalog;

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)outError;

@property (nonatomic, readonly) NSArray *allImageNames;
- (NSArray *)imagesWithName:(NSString *)name;

- (CUIStructuredThemeStore *)_themeStore;

@end