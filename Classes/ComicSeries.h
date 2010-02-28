//
//  ComicSeries.h
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

// This datatype is used when viewing information about manga in MangaSeriesController.
// If you want to switch from OneManga to another manga distributor this is where you would start.
// You need to learn XPath at http://www.w3schools.com/XPath/default.asp


#import <CoreData/CoreData.h>

@class ComicChapter;

@interface ComicSeries :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * author; // The manga author.
@property (nonatomic, retain) NSString * artist; // The manga artist
@property (nonatomic, retain) NSDate * latestRelease; // The date of the latest chapter release
@property (nonatomic, retain) NSData * coverArt; // Image data for the cover art.
@property (nonatomic, retain) NSString * link; // Weblink to the chapter. For example: http://www.onemanga.com/Anima/1/
@property (nonatomic, retain) NSString * name; // The name of the manga series
@property (nonatomic, retain) NSSet* chapters; // Set of chapters
@property (nonatomic, retain) NSNumber* latestChapterRead; // The index of the chapter last read. Do not trust the chapter.nr
@property (nonatomic, retain) NSNumber* favorite; // A boolean which says wheter it is a favorite or not.

// Downloads and parses a OneManga manga if necessary otherwise takes the ComicSeries from the database.
+ (ComicSeries *) loadLink: (NSString *) link;

// Downloads and parses a OneManga manga and puts it into the database.
+ (BOOL) downloadFromInternetIntoDBWithLink: (NSString *) link;

- (ComicChapter *) chapterAtIndex: (NSInteger) index;
- (ComicChapter *) chapterLatest; //Retrives the latest chapter
- (BOOL) updateChapterList; // Checks for new chapters
- (NSArray *) chaptersAll; // Returns a sorted list of all chapters for this manga
+ (NSArray *) getFavorites; // Returns a ComicSeries list of favorites.
+ (void) clearOfflineData; // Clears the database. Used by the Clear Cache button in SettingsController.
@end


@interface ComicSeries (CoreDataGeneratedAccessors)
- (void)addChaptersObject:(ComicChapter *)value;
- (void)removeChaptersObject:(ComicChapter *)value;
- (void)addChapters:(NSSet *)value;
- (void)removeChapters:(NSSet *)value;

@end

