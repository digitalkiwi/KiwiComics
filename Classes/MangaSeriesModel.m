//
//  MangaSeriesModel.m
//  KiwiComics
//
//  Created by Daniel Öberg on 2009-12-25.
//  Copyright 2009 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "MangaSeriesModel.h"
#import "MangaChapterModel.h"
#import "TFHpple.h"
#import "Utils.h"


@implementation MangaSeriesModel
@synthesize name;
@synthesize link;
@synthesize author;
@synthesize artist;
@synthesize description;
@synthesize coverArt;
@synthesize chapters;
@synthesize latestRelease;

- (id) initWithName: (NSString *) comicname sublink: (NSString *) l
{
    if ( self = [super init] )
    {
        [self setName:comicname];
		[self setLink:l];
    }
    return self;
}

+ (NSArray *)loadAllMangaNames
{
	NSMutableArray *result = [[NSMutableArray alloc] init];
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.onemanga.com/directory/"]];
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	NSArray *elements1  = [xpathParser search:@"//td[@class='ch-subject']/a/@href"];
	NSArray *elements2  = [xpathParser search:@"//td[@class='ch-subject']/a"];
	

	
	for (NSUInteger i=0; i<[elements1 count]; i++ ) {
		
		// Get the text within the cell tag
		NSString *completelink = [NSString stringWithFormat:@"http://www.onemanga.com%@", [[elements1 objectAtIndex:i] content]];
		MangaSeriesModel *series = [[MangaSeriesModel alloc] initWithName:[[elements2 objectAtIndex:i] content] sublink:completelink];
		[result addObject:series];
		[series release];
	}
	
	
	[xpathParser release];
	[data release];
	
	[result autorelease];
	return result;
}




- (void)fill
{
	
	//NSString *url = [NSString stringWithFormat:@"http://www.onemanga.com%@", sublink];
		
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:link]];
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	NSString *imgurl  = [[[xpathParser search:@"//div[@class='title-logo']/a/img/@src"] objectAtIndex:0] content];
	NSString *authors  = [[[xpathParser search:@"//div[@class='side-content']/p/span/a"] objectAtIndex:0] content];
	NSString *artists  = [[[xpathParser search:@"//div[@class='side-content']/p/span/a"] objectAtIndex:1] content];
	NSArray *temp_chapters  = [xpathParser search:@"//tr[@class='bg01' or @class='bg02']"];
	
	ushort nr = 1;
	
	NSMutableArray *arrayOfChapters = [[NSMutableArray alloc] init];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMM d, yyyy"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
	
	
	for (TFHppleElement *temp_chapter in temp_chapters) {
		MangaChapterModel *chapter = [[MangaChapterModel alloc] init];
		
		// Get the text within the cell tag
		NSString *chapterName = [[[[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:0]     objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		NSString *chapterLink = [[[[[[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:0]  objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		NSString *chapterDate = [[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"];
		
		chapterLink = [NSString stringWithFormat:@"http://www.onemanga.com%@", chapterLink];
		
		
		[chapter setName:chapterName];
		[chapter setLink:chapterLink];
		[chapter setNumber:nr];
		[chapter setDate:[dateFormat dateFromString:chapterDate]];
		
		[arrayOfChapters addObject: chapter];
		
		nr++;
		
		[chapter release];
	}
	
	//[self setName:mangaName];
	[self setChapters:[[arrayOfChapters reverseObjectEnumerator] allObjects]];
	[self setCoverArt:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imgurl]]];

	[self setAuthor:authors];
	[self setArtist:artists];
	//NSLog(imgurl);
	[self setLatestRelease:[[arrayOfChapters objectAtIndex:0] date]];
	
	[arrayOfChapters release];
	[dateFormat release];
	[xpathParser release];
	[data release];
}
@end
