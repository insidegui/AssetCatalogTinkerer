//
//  CoreUI.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/09/15.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CUINamedData : NSObject

@end

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

#define kCoreThemeStateNone -1

NSString *themeStateNameForThemeState(long long state) {
    switch (state) {
        case 0:
            return @"Normal";
            break;
        case 1:
            return @"Rollover";
            break;
        case 2:
            return @"Pressed";
            break;
        case 3:
            return @"Inactive";
            break;
        case 4:
            return @"Disabled";
            break;
        case 5:
            return @"DeeplyPressed";
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

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) CGImageRef unslicedImage;

@end

@interface CUICommonAssetStorage: NSObject
{
    struct _carheader {
        unsigned int _field1;
        unsigned int _field2;
        unsigned int _field3;
        unsigned int _field4;
        unsigned int _field5;
        char _field6[128];
        char _field7[256];
        unsigned char _field8[16];
        unsigned int _field9;
        unsigned int _field10;
        unsigned int _field11;
        unsigned int _field12;
    } *_header;
}

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
- (CUINamedImage *)imageWithName:(NSString *)name scaleFactor:(CGFloat)scaleFactor;


- (CUIStructuredThemeStore *)_themeStore;

@end
