//
//  AppDelegate.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 03/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "ACTAppDelegate.h"

#import "ACTMainWC.h"

// I try to keep my app delegate pretty clean, the real work is done inside window or view controllers

@interface ACTAppDelegate ()

@property (nonatomic, strong) NSMutableArray *windowControllers;

@end

@implementation ACTAppDelegate

- (NSMutableArray *)windowControllers
{
    if (!_windowControllers) _windowControllers = [NSMutableArray new];
    
    return _windowControllers;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self openAction:nil];
}

- (IBAction)openAction:(id)sender {
    ACTMainWC *controller = [self makeWindowController];
    [controller launchOpenPanel];
}

- (IBAction)exportImagesAction:(id)sender {
    [[[NSApp keyWindow] windowController] launchSavePanel];
}

/*! creates an instance of the main window controller and shows it's window */
- (ACTMainWC *)makeWindowController
{
    ACTMainWC *controller = [[ACTMainWC alloc] init];
    [self.windowControllers addObject:controller];
    
    [controller showWindow:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowControllerClosedWindow:) name:NSWindowWillCloseNotification object:controller.window];
    
    return controller;
}

- (void)windowControllerClosedWindow:(NSNotification *)note
{
    [self.windowControllers removeObject:[note.object windowController]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[note.object windowController]];
}

@end
