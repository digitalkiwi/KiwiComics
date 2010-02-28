//
//  SettingsController.h
//

// SettingsController is the controller Settings view which displays a number of toggle-buttons and regular buttons.

#import <UIKit/UIKit.h>
@class SearchController;

@interface SettingsController : UIViewController {
	IBOutlet UISwitch *animationSwitch;
	IBOutlet UISegmentedControl *zoomLevel;
	IBOutlet UISwitch *doubleTapToZoom;
	IBOutlet SearchController *searchController;
}


-(IBAction) toggleAnimations: (id) sender; // Set the animations on and off
-(IBAction) toggleZoomLevel: (id) sender;  // Sets the zoom level
-(IBAction) toggleDoubleTap: (id) sender;  // Set the double tap feature on and off
-(IBAction) refreshMangaList: (id) sender; // Calls [ComicListItem dowloadFromInternetIntoDB]. To download a new list of mangas.
-(IBAction) emptyCache: (id) sender;       // Remove all imagedata from the database.
@end
