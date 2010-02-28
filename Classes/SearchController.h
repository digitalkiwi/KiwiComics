//
//  SearchController.h
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

// SearchController is the controller for the Search view which lists all manga avaible at OneManga.
// It also contains functionality to filter the list based on search terms.

#import <UIKit/UIKit.h>
@class MangaSeriesController;

@interface SearchController : UITableViewController {
	NSMutableArray *mangas; // Array of ComicListItems
	NSMutableArray *filteredMangas; // Array of filtered ComicListItems based on the search terms
	
	IBOutlet UISearchDisplayController *searchDisplayController;
	IBOutlet UITableView *mangaTableView;
	IBOutlet MangaSeriesController *mangaSeriesController;
}

@property(retain) NSMutableArray *mangas; // Array of ComicListItems
@property(retain) NSMutableArray *filteredMangas; // Array of filtered ComicListItems based on the search terms

- (void) loadMangasFromDB; // Load the ComicListItems from the database and populate the mangas array.
@end
