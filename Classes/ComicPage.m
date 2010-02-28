// 
//  ComicPage.m
//  KiwiComics
//

#import "ComicPage.h"

#import "ComicChapter.h"

#import "Utils.h"
#import "TFHpple.h"

#import "ComicImage.h"

@implementation ComicPage 

@dynamic nr;
@dynamic image;
@dynamic link;
@dynamic chapter;
@dynamic hasImage;




- (NSData *) getImageData {
	if ([self fetchImage]) {
		return [[self image] imageData];
	}
	return nil;
}

- (BOOL) fetchImage {
	@synchronized(self) {
		
		if ([self hasImgData] == TRUE) {
			return TRUE;
		}
		
		if ([self dowloadFromInternetIntoDB] == TRUE) {
			return TRUE;
		}
	}
	return FALSE;
}

- (BOOL) fetchImageWithContext: (NSManagedObjectContext *) context  {
	//NSLog(@"Link: %@ HasData: %d ", [self link], ([self image] != nil));
	@synchronized(self) {
		if ([self hasImgData] == TRUE) {
			return TRUE;
		}
		
		if ([self downloadImgWithContext: context] == TRUE) {
			return TRUE;
		}
	}
	return FALSE;
}

- (BOOL) hasImgData {
	return ([[self hasImage] boolValue]);
}

- (BOOL) downloadImgWithContext: (NSManagedObjectContext *) context
{
	
	//NSString *url = [NSString stringWithFormat:@"http://www.onemanga.com%@%@%@", link];
	[Utils showNetworkActivity];
	NSString *l = [self loadImageUrl];
	if (l == nil) {
		l = [self loadImageUrl];
		
		if (l == nil) {
			[Utils hideNetworkActivity];
			return FALSE;
		}
	}
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:l]];
	[Utils hideNetworkActivity];
	if (data == nil) {
		return FALSE;
	}
	
	ComicImage *comicImg = [NSEntityDescription 
							insertNewObjectForEntityForName:@"ComicImage" 
							inManagedObjectContext:context];
	
	[comicImg setImageData:data];
	[comicImg setPage:self];
	
	[self setImage:comicImg];
	[self setHasImage:[NSNumber numberWithBool:TRUE]];
	[Utils saveDatabaseWithContext:[Utils databaseContext]];
	[data autorelease];
	return TRUE;
}


- (BOOL) dowloadFromInternetIntoDB
{
	return [self downloadImgWithContext: [Utils databaseContext]];
}


- (NSString *) loadImageUrl
{	
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self link]]];
	
	if (data == nil || [data length] == 0) {
		[data release];
		return nil;
	}
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	[data release];
	
	//Get all the cells of the 2nd row of the 3rd table
	NSString *result = [[[xpathParser search:@"//img[@class='manga-page']/@src[1]"] objectAtIndex:0] content];
	[xpathParser release];
	return result;
}
@end
