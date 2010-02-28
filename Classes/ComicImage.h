//
//  ComicImage.h
//  KiwiComics
//

// This database type simply contains the image from a ComicPage.

#import <CoreData/CoreData.h>

@class ComicPage;

@interface ComicImage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) ComicPage * page;

@end



