//
//  MangaPageModel.h
//  KiwiComics
//
//  Created by Daniel Öberg on 2009-12-27.
//  Copyright 2009 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MangaPageModel : NSObject {
	NSString *link;
	NSData *imageData;
}

@property(nonatomic, retain) NSString *link;

- (NSData *) imageData;
- (void) setImageData: (NSData*) d;

- (void) fill;
- (NSString *) loadImageUrl;
@end
