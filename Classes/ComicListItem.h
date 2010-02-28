//
//  ComicListItem.h
//  KiwiComics
//

// This is the database type used when listing manga in SearchController.

#import <CoreData/CoreData.h>


@interface ComicListItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name; // The name of the manga series
@property (nonatomic, retain) NSString * link; // The weblink to the manga series for example: http://www.onemanga.com/Anima/

// Get the ComicListItem list of all OneManga mangas and put them into the database.
+(void) dowloadFromInternetIntoDB;

// Retrive a list of ComicListItems from the database.
+(NSArray *) loadAllFromDB;
@end



