//
//  FavoritesController.h
//  KiwiComics
//

// FavoritesController is the controller for the Favorites view which displays a list of your favorites.

#import <UIKit/UIKit.h>
@class MangaSeriesController;
@class ComicSeries;

@interface FavoritesController : UITableViewController {
	NSArray *list; 
	
	IBOutlet UITableView *favoriteTableView;
	NSMutableDictionary *status;
	NSMutableArray *updateRowQueue;
	BOOL doneWithPrefetching;
	IBOutlet MangaSeriesController *mangaSeriesController;
}


@property(nonatomic, retain) NSArray *list; // List of ComicSeries
@property(retain) NSMutableArray *updateRowQueue; // An array containing NSIndexPaths that should be refreshed in the tableview
@property(retain) NSMutableDictionary *status; // The key is the weblink to the manga and the data is the status fetched from DownloadThread. The download progress info if you may.
@property BOOL doneWithPrefetching; // Whether we can stop updating the download progress info.

- (void) checkStatus; // Checks the download progress status of all the favorites and reflects the changes into the variable: status.
- (IBAction) updateReleaseDates; // Checks for new chapter releases
@end
