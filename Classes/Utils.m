//
//  Utils.m
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

#import "Utils.h"
#import "KiwiComicsAppDelegate.h"


@implementation Utils

+ (void) showNetworkActivity {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

+ (void) hideNetworkActivity {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
}

+ (NSString *) formattedDateRelativeToNow:(NSDate *)date {
	if (date == nil) {
		return @"";
	}
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
	[mdf release];
	
	NSUInteger dayDiff = abs((int)[midnight timeIntervalSinceNow] / (60*60*24));
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	
	if (dayDiff == 0) {
		[dateFormatter setDateFormat:@"'today ('yyyy-MM-dd')'"];
	} else if (dayDiff == 1) {
		[dateFormatter setDateFormat:@"'yesterday ('yyyy-MM-dd')'"];
	} else if (dayDiff < 31) {
		[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%lu days ago ('yyyy-MM-dd')'", dayDiff]];
	} else {
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	}
	
	return [dateFormatter stringFromDate:date];
}

+ (void) saveDatabaseWithContext: (NSManagedObjectContext *) context {
    NSError *error;
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

+ (NSManagedObjectContext *) databaseContext {
	return [((KiwiComicsAppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
}

+ (void) saveDatabase {
	@synchronized ([Utils databaseContext]) {
		[Utils saveDatabaseWithContext:[Utils databaseContext]];
	}
}

+ (void) saveDatabaseWithID: (NSString *) chapterLink {
	NSManagedObjectContext * context = [((KiwiComicsAppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContextWithID:chapterLink];
	
	@synchronized (context) {
		NSError *error;
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
}




@end
