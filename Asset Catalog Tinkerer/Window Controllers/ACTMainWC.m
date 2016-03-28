//
//  ACTMainWC.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "ACTMainWC.h"

#import "CUICatalog.h"
#import "CoreUI+TV.h"

#import "ACTAssetsTableViewController.h"

@interface ACTMainWC () <NSWindowDelegate>

@property (strong) IBOutlet ACTAssetsTableViewController *assetsController;
@property (nonatomic, copy) NSURL *fileURL;

@property (strong) IBOutlet NSView *failView;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *images;
@property (strong) CUICatalog *catalog;

@end

@implementation ACTMainWC

- (id)init
{
    self = [super initWithWindowNibName:@"ACTMainWC"];
    
    if (!self) return nil;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.backgroundColor = [NSColor whiteColor];
    [self.window setMovableByWindowBackground:YES];
}

- (void)launchOpenPanel
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowedFileTypes = @[@"app",@"car",@"framework",@"bundle",@"plugin"];
    openPanel.title = @"Select application bundle or asset catalog file";
    openPanel.prompt = @"View";
    openPanel.treatsFilePackagesAsDirectories = YES;
    openPanel.canChooseDirectories = YES;
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (!result) return;
        
        [self openFileAtURL:openPanel.URL];
    }];
}

- (NSMutableArray *)images
{
    if (!_images) _images = [NSMutableArray new];
    
    return _images;
}

- (void)openFileAtURL:(NSURL *)URL
{
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:URL];
    
    self.fileURL = URL;
    
    NSString *catalogPath = nil;
    
    // we need to figure out if the user selected an app bundle or a specific .car file
    NSBundle *bundle = [NSBundle bundleWithURL:URL];
    if (!bundle) {
        catalogPath = URL.path;
        self.window.title = catalogPath.lastPathComponent;
    } else {
        catalogPath = [bundle pathForResource:@"Assets" ofType:@"car"];
        self.window.title = [NSString stringWithFormat:@"%@ | %@", bundle.bundlePath.lastPathComponent, catalogPath.lastPathComponent];
    }
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // bundle is nil for some reason
        if (!catalogPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRunAlertPanel(@"Unable to find asset catalog path", @"The bundle doesn't have an Assets.car file", @"OK", nil, nil);
                [self showFailure];
            });
            
            return;
        }
        
        NSError *catalogError;
        self.catalog = [[CUICatalog alloc] initWithURL:[NSURL fileURLWithPath:catalogPath] error:&catalogError];
        if (catalogError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSAlert alertWithError:catalogError] runModal];
                [self showFailure];
            });
            
            return;
        }
        
        if (!self.catalog.allImageNames.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRunAlertPanel(@"No images", @"The asset catalog contains no images", @"OK", nil, nil);
                [self showFailure];
            });
            
            return;
        }
        
        for (NSString *imageName in self.catalog.allImageNames) {
            for (CUINamedImage *namedImage in [self.catalog imagesWithName:imageName]) {
                @autoreleasepool {
                    if (namedImage == nil) continue;
                    
                    NSString *filename;
                    CGImageRef image;
                    
                    if ([namedImage isKindOfClass:[CUINamedLayerStack class]]) {
                        CUINamedLayerStack *stack = (CUINamedLayerStack *)namedImage;
                        if (!stack.layers.count) continue;
                        
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
                        continue;
                    }
                    
                    [self.images addObject:@{
                                             @"name" : namedImage.name,
                                             @"image" : [[NSImage alloc] initWithData:pngData],
                                             @"filename": filename,
                                             @"png": pngData
                                             }];
                }
            }
        }
        
        // we've got no images for some reason (the console will usually contain some information from CoreUI as to why)
        if (!self.images.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRunAlertPanel(@"Failed to load images", @"The asset catalog is invalid or not present", @"Ok", nil, nil);
                [self showFailure];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // set tableview controller's items
            self.assetsController.items = self.images;
            
            // hide any previously displayed error
            [self hideFailure];
        });
    });
}

// shows an alert icon
- (void)showFailure
{
    self.failView.frame = [self.window.contentView frame];
    
    [self.scrollView setHidden:YES];
    [self.window.contentView addSubview:self.failView];
}

// hides the alert icon
- (void)hideFailure
{
    [self.failView removeFromSuperview];
    [self.scrollView setHidden:NO];
}

// invoked on command C
- (void)copy:(id)sender
{
    [self.assetsController copy:sender];
}

- (void)launchSavePanel
{
    if (!self.images.count) return;
    
    // our save panel is actually an open panel so the user can choose directories
    NSOpenPanel *savePanel = [NSOpenPanel openPanel];
    savePanel.canCreateDirectories = YES;
    savePanel.prompt = @"Export";
    savePanel.title = @"Select a directory to export the images to";
    savePanel.canChooseFiles = NO;
    savePanel.canChooseDirectories = YES;
    
    // user clicked cancel, return early
    if ([savePanel runModal] != NSFileHandlingPanelOKButton) return;
    
    // the progress is not really used right now but can be usefull in the future to display some sort of UI
    NSProgress *exportProgress = [NSProgress progressWithTotalUnitCount:self.images.count];
    exportProgress.kind = NSProgressKindFile;
    [exportProgress setUserInfoObject:NSProgressFileOperationKindCopying forKey:NSProgressFileOperationKindKey];
    [exportProgress setUserInfoObject:savePanel.URL forKey:NSProgressFileURLKey];
    [exportProgress publish];
    
    // writes all images asynchronously
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        uint64_t completed = 0;
        
        for (NSDictionary *item in self.images) {
            @autoreleasepool {
                // assemble the path for the image
                NSMutableArray *pathComponents = [[savePanel.URL pathComponents] mutableCopy];
                [pathComponents addObject:item[@"filename"]];
                
                // write tiff version of the image to disk
                [item[@"png"] writeToFile:[NSString pathWithComponents:pathComponents] atomically:YES];
                
                // update progress
                completed++;
                [exportProgress setCompletedUnitCount:completed];
            }
        }
        
        // remove the progress
        [exportProgress unpublish];
    });
    
}

@end
