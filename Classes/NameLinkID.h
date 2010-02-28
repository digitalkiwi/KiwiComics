//
//  NameLinkID.h
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

// NameLinkID is used both in the SearchController and when communicating with DownloadThread instances.


@interface NameLinkID : NSObject {
	NSString *name;
	NSString *link;
	NSManagedObjectID *objectID;
}

@property(nonatomic, copy) NSString *name; // The name of the manga
@property(nonatomic, copy) NSString *link; // The weblink to the manga series for example: http://www.onemanga.com/Anima/
@property(nonatomic, copy) NSManagedObjectID *objectID; // The object ID for the database entry. Used to because of thread-safety
@end
