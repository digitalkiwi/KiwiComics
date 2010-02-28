//
//  FavoritesController.m
//  KiwiComics
//

#import "FavoritesController.h"
#import "ComicListItem.h"
#import "ComicChapter.h"
#import "ComicPage.h"
#import "ComicSeries.h"
#import "MangaSeriesController.h"
#import "Utils.h"
#import "DownloadThread.h"
#import "NameLinkID.h"

@implementation FavoritesController
@synthesize list;
@synthesize status;
@synthesize doneWithPrefetching;
@synthesize updateRowQueue;

- (IBAction) updateReleaseDates {
	for (NameLinkID *series in list) {
		NSUInteger index = [list indexOfObject:series];
		if (index == NSNotFound) {
			continue;
		}
		
		NSString *comiclink = [series link];
		[self.status setValue:[NSString stringWithFormat:@"Checking for new chapter..."] forKey:comiclink];
		[updateRowQueue addObject:[NSIndexPath indexPathForRow:index inSection:0]];
		
		
		[((ComicSeries *)[[Utils databaseContext] objectWithID:[series objectID]]) updateChapterList];
		[self.status removeObjectForKey:comiclink];
	}
		 
}

- (void) checkStatus {
	if ([updateRowQueue count] != 0) {
		NSIndexPath *nr = [updateRowQueue objectAtIndex:0];
		[favoriteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:nr] withRowAnimation:UITableViewRowAnimationRight];
		[updateRowQueue removeObject:nr];
	}
	
	for (ComicSeries *series in list) {
		NSString *statuss = [DownloadThread getStringForSeriesLink:[series link]];
		if (statuss != nil) {
			NSIndexPath *nr = [NSIndexPath indexPathForRow:[list indexOfObject:series] inSection:0];
			[favoriteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:nr] withRowAnimation:UITableViewRowAnimationNone];
		}
	}
	
	if (![self doneWithPrefetching]) {
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkStatus) userInfo:nil repeats:NO];
	}
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self setStatus:[[NSMutableDictionary alloc] init]];
	[self setUpdateRowQueue:[[NSMutableArray alloc] init]];
	
	NSArray *favs = [ComicSeries getFavorites];
	NSMutableArray *favresult = [[NSMutableArray alloc] init];
	
	for (ComicSeries *series in favs) {
		NameLinkID *triple = [[NameLinkID alloc] init];
		[triple setName:[series name]];
		[triple setLink:[series link]];
		[triple setObjectID:[series objectID]];
		
		[favresult addObject:triple];
		[triple release];
	}
	[self setList:favresult];
	[favoriteTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[self setDoneWithPrefetching:FALSE];
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkStatus) userInfo:nil repeats:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self setDoneWithPrefetching:TRUE];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NameLinkID *series = [list objectAtIndex:indexPath.row];
	NSString *statuss = [self.status objectForKey:[series link]];
	if (statuss == nil) {
		statuss = [DownloadThread getStringForSeriesLink:[series link]];
	}
	
	//UIImage *img = [[UIImage alloc] initWithData:[series coverArt]];
	//[cell.imageView setImage:img];
	//[img release];

	if (statuss == nil) {
		cell.textLabel.text = [series name];
		ComicSeries *s = (ComicSeries *) [[Utils databaseContext] objectWithID:[series objectID]];
		cell.detailTextLabel.text = [Utils formattedDateRelativeToNow:[s latestRelease]];
	} else {
		cell.textLabel.text = [series name];
		cell.detailTextLabel.text = statuss;
	}

    
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ComicSeries *comic = [ComicSeries loadLink:[[list objectAtIndex:indexPath.row] link]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	if ((comic == nil) || ([comic link] == nil) || ([comic link] == @"")) {
		return;
	}
	[mangaSeriesController setComicSeriesID: [comic objectID]];
	

	[self presentModalViewController:mangaSeriesController animated:TRUE];
}



- (void)dealloc {
    [super dealloc];
}


@end

