//
//  ACTMainWC.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ACTMainWC : NSWindowController

- (void)launchOpenPanel;
- (void)launchSavePanel;

- (void)openFileAtURL:(NSURL *)URL;

@end
