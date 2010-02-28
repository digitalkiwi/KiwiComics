// 
//  ComicListItem.m
//  KiwiComics
//

#import "ComicListItem.h"
#import "TFHpple.h"
#import "Utils.h"

@implementation ComicListItem 

@dynamic name;
@dynamic link;

+(NSArray *) loadAllFromDB {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ComicListItem"  
											  inManagedObjectContext:context];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"name" ascending:YES];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	
	NSError *error;
	NSArray *items = [context
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	[items retain];
	[items autorelease];
	return items;
}

+(NSArray *) loadAll {
	NSArray *items = [[ComicListItem loadAllFromDB] retain];
	
	if ([items count] < 1000) {
		[ComicListItem dowloadFromInternetIntoDB];
		
		[items release];
		
		items = [[ComicListItem loadAllFromDB] retain];
	}
	[items autorelease];
	return items;
}


+(void) dowloadFromInternetIntoDB {
	NSManagedObjectContext *context = [Utils databaseContext];
	NSArray *deletelist = [self loadAllFromDB];
	for (ComicListItem *deleteitem in deletelist) {
		[context deleteObject:deleteitem];
	}
	[Utils showNetworkActivity];
	
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.onemanga.com/directory/"]];
	
	// Create parser
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
	
	//Get all the cells of the 2nd row of the 3rd table 
	NSArray *elements1  = [xpathParser search:@"//td[@class='ch-subject']/a/@href"];
	NSArray *elements2  = [xpathParser search:@"//td[@class='ch-subject']/a"];
	
	
	
	for (NSUInteger i=0; i<[elements1 count]; i++ ) {
		NSString *completelink = [NSString stringWithFormat:@"http://www.onemanga.com%@", [[elements1 objectAtIndex:i] content]];
		
		ComicListItem *item=[NSEntityDescription 
		 insertNewObjectForEntityForName:@"ComicListItem" 
							 inManagedObjectContext:context];

		[item setLink:completelink];
		[item setName:[[elements2 objectAtIndex:i] content]];
		
	}
	
	[Utils saveDatabaseWithContext:context];
	[Utils hideNetworkActivity];
	
	[xpathParser release];
	[data release];
}

@end
