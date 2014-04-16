//
//  ACTAssetsTableViewController.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ACTAssetsTableViewController : NSViewController

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readonly) NSTableView *tableView;

- (void)copy:(id)sender;

@end
