//
//  MangaChapterModel.m
//  KiwiComics
//
//  Created by Daniel Öberg on 2009-12-25.
//  Copyright 2009 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "MangaChapterModel.h"

#import "MangaSeriesModel.h"
#import "TFHpple.h"
#import "MangaPageModel.h"

@implementation MangaChapterModel
@synthesize name;
@synthesize link;
@synthesize number;
@synthesize date;

-(void) setPages: (NSArray*) p {
    [p retain];
    [pages release];
    pages = p;
}

-(NSArray *) pages {
    if (pages == nil) {
		[self fill];
	}
	return pages;
}

- (void) fill
{
	NSString *url = [MangaChapterModel loadChapterUrlWithChapter: link];
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	NSArray *temp_pages = [xpathParser search:@"//select[@id='id_page_select']/option/@value"];
	NSMutableArray *result = [[NSMutableArray alloc] init];
	
	for (TFHppleElement *temp_page in temp_pages) {
		MangaPageModel *page = [[MangaPageModel alloc] init];
		[page setLink:[NSString stringWithFormat:@"%@%@", link, [temp_page content]]];
		[result addObject:page];
		[page release];
	}
	[self setPages:result];
}

+ (NSString *) loadChapterUrlWithChapter: (NSString *) url
{	
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	return [NSString stringWithFormat:@"http://www.onemanga.com%@",[[[xpathParser search:@"//ul/li/a/@href"] objectAtIndex:0] content]];
}

@end
