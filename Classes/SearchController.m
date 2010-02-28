//
//  SearchController.m
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

#import "SearchController.h"
#import "ComicSeries.h"
#import "MangaSeriesController.h"
#import "Utils.h"
#import "KiwiComicsAppDelegate.h"
#import "ComicListItem.h"
#import "NameLinkID.h"


@implementation SearchController
@synthesize mangas;
@synthesize filteredMangas;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setMangas:[NSMutableArray array]];
	[self setFilteredMangas:[NSMutableArray array]];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([[self mangas] count] == 0) {
		[self loadMangasFromDB];
	}
}

- (void) loadMangasFromDB {
	NSArray *tmpmangas = [ComicListItem loadAllFromDB];
	
	if ([tmpmangas count] == 0) {
		[ComicListItem dowloadFromInternetIntoDB];
		tmpmangas = [ComicListItem loadAllFromDB];
	}
	
	[self setMangas:[[NSMutableArray alloc] init]];
	[self setFilteredMangas:[[NSMutableArray alloc] init]];
	
	for (ComicSeries *series in tmpmangas) {
		// KiwiComics
/* This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ */ *triple = [[NameLinkID alloc] init];
		[triple setName:[series name]];
		[triple setLink:[series link]];
		[triple setObjectID:[series objectID]];
		
		[mangas addObject:triple];
		[triple release];
	}
	[mangaTableView reloadData];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
}




#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)currentTableView numberOfRowsInSection:(NSInteger)section {
	if (mangas == nil) {
		return 0;
	}
	else if (currentTableView == mangaTableView) {
		return [mangas count];
	}
	else {
		return [filteredMangas count];
	}
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)currentTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [currentTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if ([[self mangas] count] <= indexPath.row) {
		return cell;
	}
	 // Set up the cell...
	if (currentTableView == mangaTableView) {
		cell.textLabel.text = [[[self mangas] objectAtIndex:indexPath.row] name];
		
		return cell;
	}
	else {
		cell.textLabel.text = [[[self filteredMangas] objectAtIndex:indexPath.row] name];
		
		return cell;
	}
   
	
	return nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [filteredMangas removeAllObjects]; // First clear the filtered array.
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(SELF.name contains[cd] %@)", searchString];
	
	[filteredMangas addObjectsFromArray:[mangas filteredArrayUsingPredicate:predicate]];
	
	return TRUE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSArray *usedArray = nil;
	if (tableView == mangaTableView) {
		usedArray = mangas;
	}
	else {
		usedArray = filteredMangas;
	}
	ComicSeries *comic = [ComicSeries loadLink:[[usedArray objectAtIndex:indexPath.row] link]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	if ((comic == nil) || ([comic link] == nil) || ([comic link] == @"")) {
		return;
	}
	[mangaSeriesController setComicSeriesID: [comic objectID]];
	
	//[self.navigationController pushViewController:mangaSeriesController animated:TRUE];
	[self presentModalViewController:mangaSeriesController animated:TRUE];
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

