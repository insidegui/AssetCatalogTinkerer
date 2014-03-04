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
    
    NSBundle *targetBundle = nil;
    NSString *catalogName = @"Assets";
    if ([URL.pathExtension isEqualToString:@"app"]) {
        targetBundle = [NSBundle bundleWithURL:URL];
    } else {
        NSArray *components = [URL pathComponents];
        NSString *frameworkComponent = [[components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains[cd] '.framework'"]] lastObject];
        NSMutableArray *distilledComponents;
        if (frameworkComponent) {
            distilledComponents = [[URL.path componentsSeparatedByString:frameworkComponent] mutableCopy];
            [distilledComponents removeLastObject];
            [distilledComponents addObject:frameworkComponent];
        } else {
            NSString *appComponent = [[components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains[cd] '.app'"]] lastObject];
            distilledComponents = [[URL.path componentsSeparatedByString:appComponent] mutableCopy];
            [distilledComponents removeLastObject];
            [distilledComponents addObject:appComponent];
        }
        
        NSString *bundlePath = [NSString pathWithComponents:distilledComponents];
        targetBundle = [NSBundle bundleWithPath:bundlePath];
        
        catalogName = [[components lastObject] stringByDeletingPathExtension];
        
        self.window.title = [bundlePath lastPathComponent];
    }
    
    
    if (!targetBundle) {
        NSRunAlertPanel(@"Unable to find bundle", @"The bundle could not be found", @"Ok", nil, nil);
        return [self showFailure];
    }
    
    NSArray *images = [GRAssetCatalogReader imagesFromBundle:targetBundle catalogName:catalogName];
    if (!images.count) {
        NSRunAlertPanel(@"Failed to load images", @"The asset catalog is invalid or not present", @"Ok", nil, nil);
        return [self showFailure];
    }
    
    self.assetsController.items = images;
    
    [self hideFailure];
}

- (void)showFailure
{
    self.failView.frame = [self.window.contentView frame];
    
    [self.scrollView setHidden:YES];
    [self.window.contentView addSubview:self.failView];
}

- (void)hideFailure
{
    [self.failView removeFromSuperview];
    [self.scrollView setHidden:NO];
}

- (void)copy:(id)sender
{
    [self.assetsController copy:sender];
}

- (void)launchSavePanel
{
    if (!self.assetsController.items.count) return;
    
    NSOpenPanel *savePanel = [NSOpenPanel openPanel];
    savePanel.canCreateDirectories = YES;
    savePanel.prompt = @"Export";
    savePanel.title = @"Select a directory to export the images to";
    savePanel.canChooseFiles = NO;
    savePanel.canChooseDirectories = YES;
    
    if ([savePanel runModal] != NSFileHandlingPanelOKButton) return;
    
    NSProgress *exportProgress = [NSProgress progressWithTotalUnitCount:self.assetsController.items.count];
    exportProgress.kind = NSProgressKindFile;
    [exportProgress setUserInfoObject:NSProgressFileOperationKindCopying forKey:NSProgressFileOperationKindKey];
    [exportProgress setUserInfoObject:savePanel.URL forKey:NSProgressFileURLKey];
    [exportProgress publish];
    
    uint64_t __block completed = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSDictionary *item in self.assetsController.items) {
            NSImage *image = item[@"image"];
            NSMutableArray *pathComponents = [[savePanel.URL pathComponents] mutableCopy];
            [pathComponents addObject:[item[@"name"] stringByAppendingPathExtension:@"tif"]];
            
            [[image TIFFRepresentation] writeToFile:[NSString pathWithComponents:pathComponents] atomically:YES];
            
            completed++;
            [exportProgress setCompletedUnitCount:completed];
        }
        
        [exportProgress unpublish];
    });

}

@end
