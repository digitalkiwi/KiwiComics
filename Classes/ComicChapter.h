//
//  ComicChapter.h
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

// This is the database type that contains information about a manga chapter. It is used in ReadComicController.

#import <CoreData/CoreData.h>

@class ComicPage;
@class ComicSeries;

@interface ComicChapter :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * link; // The OneManga link to this chapter
@property (nonatomic, retain) NSNumber * nr; // The chapter number.
@property (nonatomic, retain) NSString * name; // The name of the chapter
@property (nonatomic, retain) NSNumber * latestPageRead; // Latest page read in this chapter
@property (nonatomic, retain) NSDate * date; // The date this chapter was released.
@property (nonatomic, retain) NSSet* pages; // A set of ComicPages
@property (nonatomic, retain) ComicSeries * series;

// Download and parse the pages if it's not already in the database.
- (BOOL) loadPagesWithContext: (NSManagedObjectContext *) context;

// Force downloading of pages into database.
- (BOOL) downloadPagesFromInternetWithContext: (NSManagedObjectContext *) context;

// Get a array of all ComicPages (sorted).
- (NSArray *) pagesAllWithContext: (NSManagedObjectContext *) context;



// Force downloading of pages into database.
// Same as downloadPagesFromInternetWithContext but with standard database context.
- (BOOL) downloadPagesFromInternetIntoDB;

// Same as loadPagesWithContext but with standard database context.
- (BOOL) loadPages;

// Returns a chapter from the database
+ (ComicChapter *) chapterWithLink: (NSString *) link;

// Checks if a chapter exists in the database
+ (BOOL) chapterExistsWithLink: (NSString *) link;

// Returns a sorted array of ComicPages for this chapter
- (NSArray *) pagesAll;

// Checks wether all images have been downloaded for this chapter
- (BOOL) isAllImagesDownloaded;

#pragma mark Private
+ (NSString *) loadChapterUrlWithChapter: (NSString *) url;

@end


@interface ComicChapter (CoreDataGeneratedAccessors)
- (void)addPagesObject:(ComicPage *)value;
- (void)removePagesObject:(ComicPage *)value;
- (void)addPages:(NSSet *)value;
- (void)removePages:(NSSet *)value;

@end

