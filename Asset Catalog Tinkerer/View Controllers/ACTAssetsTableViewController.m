//
//  ACTAssetsTableViewController.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 04/03/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "ACTAssetsTableViewController.h"

@interface ACTAssetsTableViewController () <NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation ACTAssetsTableViewController

- (void)awakeFromNib
{
    [self.tableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

- (void)setItems:(NSArray *)items
{
    _items = [items copy];
    
    [self.tableView reloadData];
}

- (NSTableView *)tableView
{
    return (NSTableView *)self.view;
}

#pragma mark Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.items.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"Name"]) {
        return [self nameCellForRow:row];
    } else {
        return [self imageCellForRow:row];
    }
}

- (NSView *)imageCellForRow:(NSInteger)row
{
    NSTableCellView *cellView = [self.tableView makeViewWithIdentifier:@"imageCell" owner:self.tableView];
    
    cellView.imageView.image = self.items[row][@"image"];

    return cellView;
}

- (NSView *)nameCellForRow:(NSInteger)row
{
    NSTableCellView *cellView = [self.tableView makeViewWithIdentifier:@"nameCell" owner:self.tableView];
    
    cellView.textField.stringValue = self.items[row][@"filename"];
    
    return cellView;
}

- (void)copy:(id)sender
{
    [self tableView:self.tableView writeRowsWithIndexes:self.tableView.selectedRowIndexes toPasteboard:[NSPasteboard generalPasteboard]];
}

#pragma mark Pasteboard Support

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    [pboard clearContents];
    
    NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:rowIndexes.count];
    for (NSDictionary *item in [self.items objectsAtIndexes:rowIndexes]) {
        NSString *filename = item[@"filename"];
        NSData *data = item[@"png"];
        
        NSURL *tempURL = [NSURL fileURLWithPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), filename]]];
        [data writeToURL:tempURL atomically:YES];
        
        [files addObject:tempURL.path];
    }
    
    [pboard setPropertyList:[files copy] forType:NSFilenamesPboardType];

    return YES;
}

@end
