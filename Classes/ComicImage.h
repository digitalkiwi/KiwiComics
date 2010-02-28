//
//  ComicImage.h
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
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



