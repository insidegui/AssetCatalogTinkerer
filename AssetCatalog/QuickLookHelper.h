//
//  QuickLookHelper.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 02/01/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QuickLook/QuickLook.h>

@interface QuickLookHelper : NSObject

+ (OSStatus)handleQuickLookRequestWithThumbnail:(QLThumbnailRequestRef)thumbnailRequest
                                        preview:(QLPreviewRequestRef)previewRequest
                                            url:(CFURLRef)url
                                        maxSize:(CGSize)maxSize;

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size;

- (void)generatePreview;
- (void)cancel;

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly, getter=isFinished) BOOL isFinished;

- (void)drawPreview;

@end
