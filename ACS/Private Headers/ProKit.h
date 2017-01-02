//
//  ProKit.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 30/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#ifndef ProKit_h
#define ProKit_h

#import <Cocoa/Cocoa.h>

typedef struct _renditionkeytoken ProRenditionKeyToken;

@interface NSProRenditionSliceInformation : NSObject

- (struct CGRect)destinationRect;
- (double)positionOfSliceBoundary:(unsigned long long)arg1;
- (long long)renditionType;
- (struct CGSize)_bottomRightCapSize;
- (struct CGSize)_topLeftCapSize;
- (id)initWithRenditionType:(long long)arg1 destinationRect:(struct CGRect)arg2 topLeftInset:(struct CGSize)arg3 bottomRightInset:(struct CGSize)arg4;
- (id)initWithSliceInformation:(id)arg1 destinationRect:(struct CGRect)arg2;

@end

@interface NSProThemeRendition : NSObject

+ (id)displayNameForRenditionType:(long long)arg1;
+ (id)filteredPSIDataFromBasePSIData:(id)arg1;
- (unsigned int)gradientStyle;
- (id)gradient;
- (double)gradientDrawingAngle;
- (long long)themeScaleFactor;
- (BOOL)isScaled;
- (BOOL)isTiled;
- (NSProRenditionSliceInformation *)sliceInformation;
- (id)metrics;
- (id)patternForSliceIndex:(long long)arg1;
- (id)maskForSliceIndex:(long long)arg1;
- (NSImage *)imageForSliceIndex:(long long)arg1;
- (NSString *)name;
- (NSInteger)type;
- (const ProRenditionKeyToken *)key;

@end

@interface NSProRenditionKey : NSObject <NSCopying, NSCoding>

- (long long)themeScaleFactor;
- (long long)themeLayer;
- (long long)themeState;
- (long long)themeDimension2;
- (long long)themeDimension1;
- (long long)themeTint;
- (long long)themeValue;
- (long long)themeVariant;
- (long long)themeDirection;
- (long long)themeSize;
- (long long)themePart;
- (long long)themeElement;

- (ProRenditionKeyToken *)keyList;

@end

@interface NSProCommonAssetStorage : NSObject

- (NSArray <NSProRenditionKey *> *)allAssetKeys;
- (instancetype)initWithPath:(NSString *)filePath;

@end

@interface ProStructuredThemeStore : NSObject

- (NSProThemeRendition *)renditionWithKey:(const ProRenditionKeyToken *)key;
- (NSProCommonAssetStorage *)themeStore;
- (instancetype)initWithPath:(NSString *)filePath;

@end

#endif /* ProKit_h */
