//
//  MangaSeriesController.h
//  KiwiComics
//

// MangaSeriesController is the controller for the MangaSeries/Chapter view which shows a single Manga 
// and information about it and it's chapters.

#import <UIKit/UIKit.h>
@class ComicSeries;
@class ComicChapter;
@class ReadComicController;

@interface MangaSeriesController : UIViewController {
	IBOutlet UIButton *coverArtButton;
	IBOutlet UINavigationItem *navigationTitle;
	IBOutlet UIPickerView *pickerView;
	IBOutlet UILabel *artistLabel;
	IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *lastReleaseLabel;
	NSManagedObjectID *comicSeriesID;

	NSMutableDictionary *status;
	NSMutableArray *downloadList;
	NSMutableArray *chapterNameList;
	NSMutableArray *chapterLinkList;
	
	IBOutlet UIBarButtonItem *toggleFavoriteButton;
	IBOutlet UILabel *favoriteLabel;
	IBOutlet ReadComicController *readComicController;
}

-(IBAction) toggleFavorite: (id) sender;
-(IBAction) gotoFirstChapter: (id) sender;
-(IBAction) gotoLastChapter: (id) sender;
-(IBAction) gotoSelectedChapter: (id) sender;
-(IBAction) goBack: (id) sender;
-(IBAction) download: (id) sender;
- (void) gotoChapterWithNr: (NSInteger) i;
- (void) showFavoriteLabel: (BOOL) b;
@property(nonatomic, retain) NSManagedObjectID *comicSeriesID;
@property(retain) NSMutableDictionary *status;
@property(retain) NSMutableArray *downloadList;
@property(nonatomic, retain) NSMutableArray *chapterNameList;
@property(nonatomic, retain) NSMutableArray *chapterLinkList;
@end
