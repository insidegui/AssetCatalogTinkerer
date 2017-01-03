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
#define kTextDrawingRelativeSizeThreshold 2.5f

- (void)drawPreview
{
    // the number of assets actually previewed (the drawing can be aborted if there's not enough space to draw everyting)
    NSUInteger totalAssetsDrawn = 0;
    
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
    
    // calculate median size which will be used to draw the assets
    NSSize referenceSize = [self medianImageSize];
    
    // sometimes this median can be greater than the size of the viewport, so resize accordingly
    if (referenceSize.width > self.size.width - kCellMargin * 2) {
        referenceSize.width = self.size.width - kCellMargin * 2;
    }
    if (referenceSize.height > self.size.height - kCellMargin * 2) {
        referenceSize.height = self.size.height - kCellMargin * 2;
    }
    
    CGFloat x = kCellMargin;
    CGFloat y = 0;
    CGFloat lastRowHeight = 0;
    
    for (NSDictionary *asset in self.reader.images) {
        NSBitmapImageRep *rep = asset[kACSImageRepKey];
        
        NSSize size = [self fitSize:rep.size inSize:referenceSize];
        
        if (size.height > lastRowHeight) {
            lastRowHeight = size.height;
        }
        
        if (y == 0) {
            y = _size.height - size.height - kCellMargin;
        }
        
        if ((x + size.width + kCellMargin) > (self.size.width - kCellMargin)) {
            x = kCellMargin;
            y -= (lastRowHeight + kCellMargin);
            lastRowHeight = 0;
        }
        
        if ((y - size.height) < kCellMargin) break;
        
        NSRect rect = NSMakeRect(x, y, size.width, size.height);
        
        [rep drawInRect:rect];
        
        NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, -4, -4) xRadius:4 yRadius:4];
        [[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] setStroke];
        [border stroke];
        
        x += size.width + kCellMargin;
        
        // draw per-asset info (if enough space is available)
        
        NSString *assetName = [asset[kACSNameKey] stringByDeletingPathExtension];
        NSAttributedString *assetInfo = [[NSAttributedString alloc] initWithString:assetName attributes:assetTextAttrs];
        CGFloat textAreaWidth = rect.size.width + kCellMargin - kTextPadding * 2;
        
        // draw text only if the area available for it is not too small
        if (textAreaWidth > floor(assetInfo.size.width / kTextDrawingRelativeSizeThreshold)) {
            NSRect textRect = NSMakeRect(rect.origin.x + round(rect.size.width / 2.0 - textAreaWidth / 2.0),
                                         rect.origin.y - assetInfo.size.height - kTextPadding,
                                         textAreaWidth,
                                         assetInfo.size.height);
            [assetInfo drawInRect:textRect];
        }
        
        totalAssetsDrawn++;
    }
    
    // draw summary text
    
    unsigned long readCount = MIN(self.reader.totalNumberOfAssets, totalAssetsDrawn);
    
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

- (NSSize)fitSize:(NSSize)originalSize inSize:(NSSize)maxSize
{
    if (originalSize.width <= maxSize.width && originalSize.height <= maxSize.height) return originalSize;
    
    CGFloat newWidth, newHeight = 0;
    double rw = originalSize.width / maxSize.width;
    double rh = originalSize.height / maxSize.height;
    
    if (rw > rh)
    {
        newHeight = MAX(roundl(originalSize.height / rw), 1);
        newWidth = maxSize.width;
    }
    else
    {
        newWidth = MAX(roundl(originalSize.width / rh), 1);
        newHeight = maxSize.height;
    }
    
    return NSMakeSize(newWidth, newHeight);
}

- (NSNumber *)medianValueInArray:(NSArray <NSNumber *> *)input
{
    NSArray <NSNumber *> *sorted = [input sortedArrayUsingSelector:@selector(compare:)];
    NSUInteger c = input.count;
    
    if (c % 2 == 1) {
        return sorted[c / 2];
    } else {
        NSNumber *m1 = sorted[c / 2];
        NSNumber *m2 = sorted[c / 2 - 1];
        
        return @((m1.doubleValue + m2.doubleValue) / 2);
    }
}

- (NSSize)medianImageSize
{
    NSMutableArray <NSNumber *> *widths = [[NSMutableArray alloc] initWithCapacity:self.reader.images.count];
    NSMutableArray <NSNumber *> *heights = [[NSMutableArray alloc] initWithCapacity:self.reader.images.count];
    
    [self.reader.images enumerateObjectsUsingBlock:^(NSDictionary* asset, NSUInteger idx, BOOL *stop) {
        NSBitmapImageRep *rep = asset[kACSImageRepKey];
        [widths addObject:@(rep.size.width)];
        [heights addObject:@(rep.size.height)];
    }];
    
    NSNumber *medianWidth = [self medianValueInArray:widths];
    NSNumber *medianHeight = [self medianValueInArray:heights];
    
    return NSMakeSize(round(medianWidth.doubleValue), round(medianHeight.doubleValue));
}

@end
