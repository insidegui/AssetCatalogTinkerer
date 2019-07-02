//
//  NSPasteboard+Filenames.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 02/07/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPasteboard (Filenames)

- (void)setFilenamesPropertyListWithFilenames:(NSArray <NSString *> *)filenames;
- (NSArray <NSString *> *__nullable)filenamesPropertyList;

@end

NS_ASSUME_NONNULL_END
