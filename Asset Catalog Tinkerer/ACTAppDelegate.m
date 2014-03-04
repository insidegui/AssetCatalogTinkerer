//
//  AppDelegate.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 03/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "ACTAppDelegate.h"

#import "ACTMainWC.h"

@interface ACTAppDelegate ()

@property (nonatomic, strong) ACTMainWC *mainWC;

@end

@implementation ACTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initializeInterface];
    
    [self.mainWC.window center];
    [self.mainWC launchOpenPanel];
}

- (IBAction)openAction:(id)sender {
    if (!self.mainWC) [self initializeInterface];
    
    [self.mainWC launchOpenPanel];
}

- (IBAction)exportImagesAction:(id)sender {
    if (!self.mainWC) return;
    
    [self.mainWC launchSavePanel];
}

- (void)initializeInterface
{
    self.mainWC = [[ACTMainWC alloc] init];
    [self.mainWC showWindow:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowClosed) name:NSWindowWillCloseNotification object:self.mainWC.window];
}

- (void)mainWindowClosed
{
    self.mainWC = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
