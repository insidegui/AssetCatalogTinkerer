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
    self.window.title = [URL.path lastPathComponent];
    
    // this will hold the bundle
    NSBundle *targetBundle = nil;
    
    // default asset catalog file name
    NSString *catalogName = @"Assets";
    
    // we need to figure out if the user selected an app bundle or a specific .car file
    if ([URL.pathExtension isEqualToString:@"app"]) {
        // selected app bundle
        targetBundle = [NSBundle bundleWithURL:URL];
    } else {
        // here the user selected a specific .car file, now we need to figure out the bundle it belongs to
        NSArray *components = [URL pathComponents];
        
        // see if the bundle is a framework bundle
        NSString *frameworkComponent = [[components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains[cd] '.framework'"]] lastObject];
        NSMutableArray *distilledComponents;
        if (frameworkComponent) {
            // framework bundle
            distilledComponents = [[URL.path componentsSeparatedByString:frameworkComponent] mutableCopy];
            [distilledComponents removeLastObject];
            [distilledComponents addObject:frameworkComponent];
        } else {
            // app bundle
            NSString *appComponent = [[components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains[cd] '.app'"]] lastObject];
            distilledComponents = [[URL.path componentsSeparatedByString:appComponent] mutableCopy];
            [distilledComponents removeLastObject];
            [distilledComponents addObject:appComponent];
        }
        
        // finally, assemble the final path and get the bundle
        NSString *bundlePath = [NSString pathWithComponents:distilledComponents];
        targetBundle = [NSBundle bundleWithPath:bundlePath];
        
        // get the asset catalog file name
        catalogName = [[components lastObject] stringByDeletingPathExtension];
        
        // set the title to the bundle's file name
        self.window.title = [bundlePath lastPathComponent];
    }
    
    // bundle is nil for some reason
    if (!targetBundle) {
        NSRunAlertPanel(@"Unable to find bundle", @"The bundle could not be found", @"Ok", nil, nil);
        return [self showFailure];
    }
    
    // this uses our convenience class to get a collection of images from the bundle
    NSArray *images = [GRAssetCatalogReader imagesFromBundle:targetBundle catalogName:catalogName];
    
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
            // assemble the path for the image
            NSImage *image = item[@"image"];
            NSMutableArray *pathComponents = [[savePanel.URL pathComponents] mutableCopy];
            [pathComponents addObject:[item[@"name"] stringByAppendingPathExtension:@"tif"]];
            
            // write tiff version of the image to disk
            [[image TIFFRepresentation] writeToFile:[NSString pathWithComponents:pathComponents] atomically:YES];
            
            // update progress
            completed++;
            [exportProgress setCompletedUnitCount:completed];
        }
        
        // remove the progress
        [exportProgress unpublish];
    });

}

@end
