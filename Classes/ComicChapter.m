// 
//  ComicChapter.m
//  KiwiComics
//

#import "ComicChapter.h"

#import "ComicPage.h"
#import "ComicSeries.h"
#import "Utils.h"
#import "TFHpple.h"

@implementation ComicChapter 

@dynamic link;
@dynamic nr;
@dynamic name;
@dynamic date;
@dynamic pages;
@dynamic series;
@dynamic latestPageRead;




- (BOOL) loadPages {
	if ([[self pages] count] == 0) {
		[self downloadPagesFromInternetIntoDB];
		if ([[self pages] count] == 0)
			return FALSE;
	} 
	return TRUE;
}

- (BOOL) loadPagesWithContext: (NSManagedObjectContext *) context {
	if ([self pages] == nil) {
		[self downloadPagesFromInternetWithContext:context];
	}
	if (([self pages] == nil || [self pages] == NULL) || ([[self pages] count] == 0)) {
		[self downloadPagesFromInternetWithContext:context];
		if ([[self pages] count] == 0)
			return FALSE;
	} 
	return TRUE;
}

- (BOOL) downloadPagesFromInternetIntoDB
{
	[self downloadPagesFromInternetWithContext:[Utils databaseContext]];
	[Utils saveDatabaseWithContext:[Utils databaseContext]];
	return TRUE;
}

- (BOOL) downloadPagesFromInternetWithContext: (NSManagedObjectContext *) context
{
	[Utils showNetworkActivity];

	NSString *url = [ComicChapter loadChapterUrlWithChapter: [self link]];
	if ([self link] == nil || url == nil) {
		return FALSE;
	}
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
	[Utils hideNetworkActivity];
	if (data == nil) {
		return FALSE;
	}
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	[data release];
	
	//Get all the cells of the 2nd row of the 3rd table 
	NSArray *temp_pages = [xpathParser search:@"//select[@id='id_page_select']/option/@value[1]"];
	[xpathParser release];
	ushort nr = 0;
	
	for (TFHppleElement *temp_page in temp_pages) {
		ComicPage *page = [NSEntityDescription 
						   insertNewObjectForEntityForName:@"ComicPage" 
						   inManagedObjectContext:context];
		[page setLink:[NSString stringWithFormat:@"%@%@", [self link], [temp_page content]]];
		[page setNr:[NSNumber numberWithUnsignedShort:nr]];
		
		[self addPagesObject:page];
		nr++;
	}
	return TRUE;
}

- (BOOL) isAllImagesDownloaded {
	if ([[self pages] count] == 0) {
		return NO;
	}
	NSSet *a = [self pages];
	for (ComicPage *p in a)  {
		if (![p hasImgData]) {
			return NO;
		}
	}
	return TRUE;
}

+ (NSString *) loadChapterUrlWithChapter: (NSString *) url
{	
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
	
	if (data == nil) {
		return nil;
	}
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	[data release];
	
	NSString *result = [NSString stringWithFormat:@"http://www.onemanga.com%@",[[[xpathParser search:@"//ul/li/a/@href[1]"] objectAtIndex:0] content]];
	
	[xpathParser release];
	//Get all the cells of the 2nd row of the 3rd table 
	return result;
}

- (ComicPage *) pageAtIndex: (NSInteger) index {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicPage"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"chapter=%@", self];
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
	if ([items count] == 0) {
		return nil;
	}
	ComicPage *page = [items objectAtIndex:index]; 
	return [[page retain] autorelease];
}

- (NSArray *) pagesAll {
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"nr"
												 ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
	[descriptor release];
	return [[[self pages] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
	
}

- (NSArray *) pagesAllWithContext: (NSManagedObjectContext *) context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicPage"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"chapter=%@", self];
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

+ (ComicChapter *) chapterWithLink: (NSString *) link  {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicChapter"  
											  inManagedObjectContext:context];
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"link=%@", link];
	
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	
	[fetchRequest release];
	if ([items count] == 0) {
		return nil;
	}
	ComicChapter *chapter = [items objectAtIndex:0]; 
	return [[chapter retain] autorelease];
}

+ (BOOL) chapterExistsWithLink: (NSString *) link  {
	return ([ComicChapter chapterWithLink: link] != nil);
}
@end
