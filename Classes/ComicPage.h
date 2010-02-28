//
//  ComicPage.h
//  KiwiComics
//

// This is the database type used when viewing a comicpage in ReadComicController.
// It does not contain the image data (ComicImage does) because we don't want to accidently load complete
// images and cause memory overload.

#import <CoreData/CoreData.h>

@class ComicChapter;
@class ComicImage;

@interface ComicPage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * nr; // The page number, should only be used for sorting
@property (nonatomic, retain) ComicImage * image; // The pointer to a class with the manga page image
@property (nonatomic, retain) NSString * link; // The link to the manga page (that will be parsed for the manga image). 
                                               // Not the link to the manga image itself.

@property (nonatomic, retain) ComicChapter * chapter; // The chapter this page belongs to.
@property (nonatomic, retain) NSNumber * hasImage; // Boolean expression to wether ComicImage contains the image yet.


// Downloads the image and puts it into the database. Even if the image is already downloaded.
- (BOOL) dowloadFromInternetIntoDB; 
// Downloads the image only if it isn't already in the database.
- (BOOL) fetchImage;
// Downloads the image if necessary and then returns the image data.
- (NSData *) getImageData;




#pragma mark Private
- (NSString *) loadImageUrl;
- (BOOL) hasImgData;

- (BOOL) downloadImgWithContext: (NSManagedObjectContext *) context;
- (BOOL) fetchImageWithContext: (NSManagedObjectContext *) context;
@end



