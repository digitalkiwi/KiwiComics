//
//  NameLinkID.h
//  KiwiComics
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
