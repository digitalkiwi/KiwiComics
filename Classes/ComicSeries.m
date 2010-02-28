// 
//  ComicSeries.m
//  KiwiComics
//

#import "ComicSeries.h"

#import "ComicChapter.h"
#import "Utils.h"
#import "TFHpple.h"

@implementation ComicSeries 

@dynamic author;
@dynamic artist;
@dynamic latestRelease;
@dynamic coverArt;
@dynamic link;
@dynamic name;
@dynamic chapters;
@dynamic latestChapterRead;
@dynamic favorite;

+(ComicSeries *) loadCachedWithLink: (NSString *) link {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicSeries"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"link=%@", link];
	
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];

	
	if ([items count] <= 0) {
		return nil;
	}
	
	ComicSeries *item=[items objectAtIndex:0];
	return [[item retain] autorelease];
}

+ (ComicSeries *)loadLink: (NSString *) link
{
	ComicSeries *series = [ComicSeries loadCachedWithLink: link];
	if (series == nil) {
		[ComicSeries downloadFromInternetIntoDBWithLink:link];
		
		series = [ComicSeries loadCachedWithLink:link];
		
	}
	return series;
}

+ (BOOL)downloadFromInternetIntoDBWithLink: (NSString *) link
{
	[Utils showNetworkActivity];
	NSManagedObjectContext *context = [Utils databaseContext];
	
	ComicSeries *series=[NSEntityDescription 
						 insertNewObjectForEntityForName:@"ComicSeries" 
						 inManagedObjectContext:context];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:link]];
	[Utils hideNetworkActivity];
	if (data == nil) {
		return FALSE;
	}
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	NSString *title  = @"";
	NSString *imgurl  = @"";
	NSString *authors  = @"";
	NSString *artists  = @"";
	NSArray *temp_chapters = nil;
	
	NS_DURING
	authors  = [[[xpathParser search:@"//div[@class='side-content']/p/span/a[1]"] objectAtIndex:0] content];
	artists  = [[[xpathParser search:@"//div[@class='side-content']/p[2]/span/a[1]"] objectAtIndex:0] content];
	NS_HANDLER
	NSLog(@"->downloadFromInternetIntoCacheWithLink: Could not load img, author or artist");
	NS_ENDHANDLER
	
	NS_DURING
	imgurl  = [[[xpathParser search:@"//div[@class='title-logo']/a/img/@src[1]"] objectAtIndex:0] content];
	title  = [[[xpathParser search:@"//div[@class='side-content']/span[1]"] objectAtIndex:0] content];
	temp_chapters  = [xpathParser search:@"//tr[@class='bg01' or @class='bg02']"];
	NS_HANDLER
	NSLog(@"->downloadFromInternetIntoCacheWithLink: Could not load title");
	return FALSE;
	NS_ENDHANDLER
	
	[series setName:title];
	[series setLink:link];
	[series setAuthor:authors];
	[series setArtist:artists];
	
	[series setCoverArt:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imgurl]]];
	
	ushort nr = [temp_chapters count] - 1;
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
	[dateFormat setDateFormat:@"MMM d, yyyy"];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormat setLocale:locale];
	[locale release];
	

	
	for (TFHppleElement *temp_chapter in temp_chapters) {
		// Get the text within the cell tag
		NSString *chapterName = [[[[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:0]     objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		NSString *chapterLink = [[[[[[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:0]  objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		NSString *chapterDate = [[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"];
		
		//NSLog(@"DATE: %@", [[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"]);
		if (chapterLink == nil) {
			continue;
		}
		
		ComicChapter *chapter = [NSEntityDescription 
								 insertNewObjectForEntityForName:@"ComicChapter" 
								 inManagedObjectContext:context];
		

		
		chapterLink = [NSString stringWithFormat:@"http://www.onemanga.com%@", chapterLink];
		
		if (nr == ([temp_chapters count] - 1)) {
			[series setLatestRelease:[dateFormat dateFromString:chapterDate]];
		}
		
		[chapter setName:chapterName];
		[chapter setLink:chapterLink];
		[chapter setNr:[NSNumber numberWithUnsignedShort:nr]];
		[chapter setDate:[dateFormat dateFromString:chapterDate]];
		
		[series addChaptersObject: chapter];
		
		nr--;
		
	}
	
	[Utils saveDatabaseWithContext:context];

	
	[dateFormat release];
	[xpathParser release];
	[data release];
	return TRUE;
}

- (ComicChapter *) chapterLatest {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicChapter"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"series=%@", self];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"date" ascending:NO];
	
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	
	if ([items count] <= 0) {
		return nil;
	}
	
	ComicChapter *item=[items objectAtIndex:0];
	return [[item retain] autorelease];
}

- (BOOL)updateChapterList
{
	[Utils showNetworkActivity];
	NSManagedObjectContext *context = [Utils databaseContext];
	
	if ([self link] == nil) {
		return FALSE;
	}
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self link]]];
	[Utils hideNetworkActivity];
	if (data == nil) {
		return FALSE;
	}
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	

	NSArray *temp_chapters = [xpathParser search:@"//tr[@class='bg01' or @class='bg02']"];
	

	if ([temp_chapters count] == [[self chapters] count]) {
		[xpathParser release];
		[data release];
		return TRUE;
	}
	ushort nr = [temp_chapters count] - 1;
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMM d, yyyy"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
	
	
	
	for (TFHppleElement *temp_chapter in temp_chapters) {
		NSString *chapterName = [[[[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:0]     objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		NSString *chapterLink = [[[[[[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:0]  objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		NSString *chapterDate = [[[[temp_chapter node] objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"];
		chapterLink = [NSString stringWithFormat:@"http://www.onemanga.com%@", chapterLink];
		
		if (![ComicChapter chapterExistsWithLink:chapterLink]) {
			ComicChapter *chapter = [NSEntityDescription 
									 insertNewObjectForEntityForName:@"ComicChapter" 
									 inManagedObjectContext:context];
			
			if (nr == ([temp_chapters count] - 1)) {
				[self setLatestRelease:[dateFormat dateFromString:chapterDate]];
			}
			
			[chapter setName:chapterName];
			[chapter setLink:chapterLink];
			[chapter setNr:[NSNumber numberWithUnsignedShort:nr]];
			[chapter setDate:[dateFormat dateFromString:chapterDate]];
			//[chapter setSeries:self];
			
			[self addChaptersObject: chapter];
		}
		

		
		nr--;
		
	}
	
	[Utils saveDatabaseWithContext:context];
	
	
	[dateFormat release];
	[xpathParser release];
	[data release];
	return TRUE;
}


- (ComicChapter *) chapterAtIndex: (NSInteger) index {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicChapter"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"series=%@", self];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"nr" ascending:YES];
	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	if (index >= [items count] ) {
		NSLog(@"->chapterAtIndex Couldn't retrive chapter");
		return nil;
	}
	
	ComicChapter *item=[items objectAtIndex:index];
	return [[item retain] autorelease];
}

- (NSArray *) chaptersAll {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicChapter"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"series=%@", self];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"nr" ascending:YES];
	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	return items;
}

+ (NSArray *) getFavorites {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicSeries"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"favorite=%@", [NSNumber numberWithBool:TRUE]];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"latestRelease" ascending:NO];
	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	return items;
}

+ (void) clearOfflineData {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicSeries"  
											  inManagedObjectContext:context];
	
	
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	for (ComicSeries *s in items) {
		NSLog(@"Deleting: %@", [s name]);
		
		NSSet *setofchapters = [s chapters];
		
		for (ComicChapter *c in setofchapters) {
			NSSet *setofpages = [c pages];
			
			for (ComicPage *p in setofpages) {
				[context deleteObject: (NSManagedObject *) p];
			}
			
		}
	}
	
	[fetchRequest release];
	
	if (![context save:&error]) {
		NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				NSLog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			NSLog(@"  %@", [error userInfo]);
		}
	}
	
}

@end
