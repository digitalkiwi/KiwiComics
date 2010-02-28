//
//  MangaPageModel.m
//  KiwiComics
//
//  Created by Daniel Öberg on 2009-12-27.
//  Copyright 2009 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "MangaPageModel.h"
#import "MangaSeriesModel.h"
#import "MangaChapterModel.h"
#import "TFHpple.h"

@implementation MangaPageModel
@synthesize link;

- (id) initWithLink: (NSString *) l
{
    if ( self = [super init] )
    {
        [self setLink:l];
		imageData = nil;
    }
    return self;
}

- (NSData *) imageData {
	@synchronized(self) {
	if (imageData == nil) {
		[self fill];
	}
	}
    return imageData;
}

- (void) setImageData: (NSData*) d {
    [d retain];
    [imageData release];
    imageData = d;
}

- (void) fill
{
	//NSString *url = [NSString stringWithFormat:@"http://www.onemanga.com%@%@%@", link];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self loadImageUrl]]];
	[self setImageData:data];
	[data autorelease];
}

- (NSString *) loadImageUrl
{	
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:link]];
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	return [[[xpathParser search:@"//img[@class='manga-page']/@src"] objectAtIndex:0] content];
}
@end
