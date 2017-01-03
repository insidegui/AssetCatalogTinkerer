//
//  QuickLookHelper.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 02/01/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

#import "QuickLookHelper.h"

#import <ACS/ACS.h>

#define kMaxNumberOfAssets 100

@interface QuickLookHelper ()

@property (nonatomic, strong) AssetCatalogReader *reader;
@property (nonatomic, assign) CGSize size;

@end

@implementation QuickLookHelper

+ (OSStatus)handleQuickLookRequestWithThumbnail:(QLThumbnailRequestRef)thumbnailRequest
                                        preview:(QLPreviewRequestRef)previewRequest
                                            url:(CFURLRef)url
                                        maxSize:(CGSize)maxSize
{
    QuickLookHelper *generator = [[QuickLookHelper alloc] initWithURL:(__bridge NSURL *)url size:NSMakeSize(500, 700)];
    
    [generator generatePreview];
    
    while (!generator.isFinished) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
    }
    
    CGContextRef ctx;
    if (previewRequest) {
        ctx = QLPreviewRequestCreateContext(previewRequest, generator.size, false, NULL);
    } else {
        ctx = QLThumbnailRequestCreateContext(thumbnailRequest, generator.size, false, NULL);
    }
    
    if (!ctx) return -1;
    
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)ctx flipped:NO];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    
    [generator drawPreview];
    
    if (previewRequest) {
        QLPreviewRequestFlushContext(previewRequest, ctx);
    } else {
        QLThumbnailRequestFlushContext(thumbnailRequest, ctx);
    }
    
    return noErr;
}

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size
{
    if (!(self = [super init])) return nil;
    
    _reader = [[AssetCatalogReader alloc] initWithFileURL:url];
    _size = size;
    
    return self;
}

- (void)generatePreview
{
    [self.reader resourceConstrainedReadWithMaxCount:kMaxNumberOfAssets completionHandler:^{
        _isFinished = YES;
    }];
}

- (void)cancel
{
    [self.reader cancelReading];
}

#define kCellMargin 28.0f
#define kTextPadding 8.0f

- (void)drawPreview
{
    // text attributes for per-asset info
    
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.alignment = NSTextAlignmentCenter;
    pStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *assetTextAttrs = @{
                                     NSFontAttributeName: [NSFont systemFontOfSize:8.0],
                                     NSForegroundColorAttributeName: [NSColor grayColor],
                                     NSParagraphStyleAttributeName: pStyle
                                     };
    
    // fill background
    
    [[NSColor whiteColor] setFill];
    NSRectFill(NSMakeRect(0, 0, _size.width, _size.height));
    
    // draw asset grid
    
    CGFloat x = kCellMargin;
    CGFloat y = 0;
    CGFloat lastRowHeight = 0;
    
    for (NSDictionary *asset in self.reader.images) {
        NSBitmapImageRep *rep = asset[kACSImageRepKey];
        
        if (rep.size.height > lastRowHeight) {
            lastRowHeight = rep.size.height;
        }
        
        if (y == 0) {
            y = _size.height - rep.size.height - kCellMargin;
        }
        
        if ((x + rep.size.width + kCellMargin) > (self.size.width - kCellMargin)) {
            x = kCellMargin;
            y -= (lastRowHeight + kCellMargin);
            lastRowHeight = 0;
        }
        
        if ((y - rep.size.height) < kCellMargin) break;
        
        NSRect rect = NSMakeRect(x, y, rep.size.width, rep.size.height);
        
        [rep drawInRect:rect];
        
        NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, -4, -4) xRadius:4 yRadius:4];
        [[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] setStroke];
        [border stroke];
        
        x += rep.size.width + kCellMargin;
        
        // draw per-asset info (if enough space is available)
        
        NSString *assetName = [asset[kACSNameKey] stringByDeletingPathExtension];
        NSAttributedString *assetInfo = [[NSAttributedString alloc] initWithString:assetName attributes:assetTextAttrs];
        CGFloat textAreaWidth = rect.size.width + kCellMargin - kTextPadding * 2;
        if (textAreaWidth > assetInfo.size.width / 2) {
            NSRect textRect = NSMakeRect(rect.origin.x + round(rect.size.width / 2.0 - textAreaWidth / 2.0),
                                         rect.origin.y - assetInfo.size.height - kTextPadding,
                                         textAreaWidth,
                                         assetInfo.size.height);
            [assetInfo drawInRect:textRect];
        }
    }
    
    // draw summary text
    
    unsigned long readCount = MIN(self.reader.totalNumberOfAssets, kMaxNumberOfAssets);
    
    NSDictionary *attrs = @{
                            NSFontAttributeName: [NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium],
                            NSForegroundColorAttributeName: [NSColor grayColor]
                            };
    NSString *info = [NSString stringWithFormat:@"Previewing %lu of %lu assets", readCount, (unsigned long)self.reader.totalNumberOfAssets];
    NSAttributedString *summary = [[NSAttributedString alloc] initWithString:info attributes:attrs];
    
    CGFloat tw = summary.size.width;
    CGFloat th = summary.size.height;
    NSRect summaryRect = NSMakeRect(round(_size.width / 2.0 - tw / 2.0), kCellMargin, tw, th);
    
    [summary drawInRect:summaryRect];
}

@end
