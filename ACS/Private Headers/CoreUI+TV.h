//
//  CoreUI+TV.h
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 22/11/15.
//  Copyright © 2015 Guilherme Rambo. All rights reserved.
//

#ifndef CoreUI_TV_h
#define CoreUI_TV_h

#import "CoreUI.h"

@interface CUINamedLayerStack : CUINamedImage

@property(retain, nonatomic) NSArray *layers; // @synthesize layers=_layers;

@property(readonly, nonatomic) struct CGImage *radiosityImage;
@property(readonly, nonatomic) struct CGImage *flattenedImage;
- (id)layerImageAtIndex:(unsigned long long)arg1;
@property(readonly, nonatomic) struct CGSize size;

@end

@interface CUINamedLayerImage : CUINamedImage

@property(nonatomic) int blendMode; // @synthesize blendMode=_blendMode;
@property(nonatomic) double opacity; // @synthesize opacity=_opacity;
@property(nonatomic) struct CGRect frame; // @synthesize frame=_frame;

@end

#endif /* CoreUI_TV_h */
