//
//  NSPasteboard+Filenames.m
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 02/07/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

#import "NSPasteboard+Filenames.h"

@implementation NSPasteboard (Filenames)

- (void)setFilenamesPropertyListWithFilenames:(NSArray <NSString *> *)filenames
{
    [self setPropertyList:filenames forType:NSPasteboardTypeString];
}

- (NSArray<NSString *> *)filenamesPropertyList
{
    return [self propertyListForType:NSPasteboardTypeString];
}

@end
