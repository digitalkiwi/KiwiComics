//
//  DownloadThread.m
//  KiwiComics
//

#import "DownloadThread.h"
#import "ComicChapter.h"
#import "ComicPage.h"
#import "KiwiComicsAppDelegate.h"
#import "Utils.h"

static NSMutableArray *listOfChapterIDs;
static NSMutableDictionary *status;
static NSMutableDictionary *statusEnums;
static NSManagedObjectContext * context;

@implementation DownloadThread

+ (void) start {
	listOfChapterIDs = [[NSMutableArray alloc] init];
	status = [[NSMutableDictionary alloc] init];
	statusEnums = [[NSMutableDictionary alloc] init];
	context = [((KiwiComicsAppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContextWithID:@"DownloadThread"];
	[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil]; 
}

+ (void) run {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	while (![[NSThread currentThread] isCancelled]) {
		while ([listOfChapterIDs count] != 0) {
			NSManagedObjectID *chapterID = nil;
			@synchronized (listOfChapterIDs) {
				chapterID = [[listOfChapterIDs objectAtIndex:0] retain];
				[listOfChapterIDs removeObjectAtIndex:0];
			}
			
			ComicChapter *chapter = (ComicChapter *) [context objectWithID:chapterID];
			NSString *chapterLink = [[chapter link] copy];
			NSString *seriesLink = [[chapter series] link];
			
			@synchronized (statusEnums) {
				[statusEnums setObject:[NSNumber numberWithInt:DOWNLOADING] forKey:chapterLink];
			}
			
			
			NSArray *pages = [chapter pagesAll];
			for (NSUInteger currentPage=0; currentPage < [pages count]; currentPage++) {
				[[pages objectAtIndex:currentPage] fetchImageWithContext:context];
				[Utils saveDatabaseWithContext: context];
				
				@synchronized (status) {
					[status setValue:[NSString stringWithFormat:@"%@ (%ld/%lu)",[chapter name] ,(currentPage+1),[pages count]] forKey:seriesLink];
				}
			}
			

			
			@synchronized (status) {
				[status setValue:[NSString stringWithFormat:@"%@ (done)",[chapter name]] forKey:[[chapter series] link]];
			}
			[chapterID release];
			
			[chapterLink release];
			
			@synchronized (statusEnums) {
				[statusEnums setObject:[NSNumber numberWithInt:NONE] forKey:chapterLink];
			}
			
		}
		[NSThread sleepForTimeInterval:0.5];
	}
	[pool release]; 
}

+ (void) downloadChapterWithID: (NSManagedObjectID *) chapterID {
	@synchronized (listOfChapterIDs) {
		[listOfChapterIDs addObject:chapterID];
	}
}

+ (NSString *) getStringForSeriesLink: (NSString *) series {
	@synchronized (status) {
		return [status objectForKey:series];
	}
	return @"";
}

+ (DownloadStatus) getDownloadStatusForChapterLink: (NSString *) link {
	@synchronized (statusEnums) {
		NSNumber *nr = [statusEnums objectForKey:link];
		if (nr == nil) {
			return NONE;	
		}
		DownloadStatus s = [nr intValue];
		
		return s;
	}
	return NONE;
}

@end
