//
//  ACTMainWC.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "ACTMainWC.h"

#import "GRAssetCatalogReader.h"

#import "ACTAssetsTableViewController.h"

@interface ACTMainWC () <NSWindowDelegate>

@property (strong) IBOutlet ACTAssetsTableViewController *assetsController;
@property (nonatomic, copy) NSURL *fileURL;

@property (strong) IBOutlet NSView *failView;
@property (weak) IBOutlet NSScrollView *scrollView;

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
    openPanel.allowedFileTypes = @[@"app",@"car"];
    openPanel.title = @"Select application bundle or asset catalog file";
    openPanel.prompt = @"View";
    openPanel.treatsFilePackagesAsDirectories = YES;
    openPanel.canChooseDirectories = YES;
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) [self handleOpeningFileAtURL:openPanel.URL];
}

- (void)handleOpeningFileAtURL:(NSURL *)URL
{
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
    
    // bundle is nil for some reason
    if (!catalogPath) {
        NSRunAlertPanel(@"Unable to find asset catalog path", @"The bundle doesn't have an Assets.car file", @"OK", nil, nil);
        return [self showFailure];
    }
    
    // this uses our convenience class to get a collection of images from the bundle
    NSArray *images = [GRAssetCatalogReader imagesFromCatalogAtURL:[NSURL fileURLWithPath:catalogPath]];
    
    // we've got no images for some reason (the console will usually contain some information from CoreUI as to why)
    if (!images.count) {
        NSRunAlertPanel(@"Failed to load images", @"The asset catalog is invalid or not present", @"Ok", nil, nil);
        return [self showFailure];
    }
    
    // set tableview controller's items
    self.assetsController.items = images;
    
    // hide any previously displayed error
    [self hideFailure];
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
    if (!self.assetsController.items.count) return;
    
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
    NSProgress *exportProgress = [NSProgress progressWithTotalUnitCount:self.assetsController.items.count];
    exportProgress.kind = NSProgressKindFile;
    [exportProgress setUserInfoObject:NSProgressFileOperationKindCopying forKey:NSProgressFileOperationKindKey];
    [exportProgress setUserInfoObject:savePanel.URL forKey:NSProgressFileURLKey];
    [exportProgress publish];
    
    // writes all images asynchronously
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        uint64_t completed = 0;

        for (NSDictionary *item in self.assetsController.items) {
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
