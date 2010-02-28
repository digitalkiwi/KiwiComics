//
//  Utils.h
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {

}

// Takes a date and outputs a string telling how many days ago the date was 
// or if it was over a month ago spits out the date.
+ (NSString *) formattedDateRelativeToNow:(NSDate *)date;

// Saves the data in the context to the permanent storage (harddrive)
+ (void) saveDatabaseWithContext: (NSManagedObjectContext *) context;

// Gets a default database context. Should not be used by DownloadThread
+ (NSManagedObjectContext *) databaseContext;

// Show/Hide the Network Activity circle in the statusbar.
+ (void) showNetworkActivity;
+ (void) hideNetworkActivity;

// Save the default database context to the permanent storage.
+ (void) saveDatabase;

+ (void) saveDatabaseWithID: (NSString *) chapterLink;
@end
