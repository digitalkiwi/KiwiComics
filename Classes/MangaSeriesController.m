//
//  MangaSeriesController.m
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

#import "MangaSeriesController.h"
#import "ComicSeries.h"
#import "ReadComicController.h"
#import "Utils.h"
#import "KiwiComicsAppDelegate.h"
#import "ComicListItem.h"
#import "ComicPage.h"
#import "ComicChapter.h"
#import "DownloadThread.h"

@implementation MangaSeriesController

@synthesize comicSeriesID;
@synthesize status;
@synthesize downloadList;
@synthesize chapterNameList;
@synthesize chapterLinkList;


-(IBAction) toggleFavorite: (id) sender
{
	ComicSeries *comicSeries = (ComicSeries *) [[Utils databaseContext] objectWithID:comicSeriesID];
	BOOL isFavorite = [[comicSeries favorite] boolValue];
	isFavorite = !isFavorite;
	[comicSeries setFavorite:[NSNumber numberWithBool:isFavorite]];
	[self showFavoriteLabel:isFavorite];
	[Utils saveDatabase];
}

-(IBAction) download: (id) sender 
{
	NSInteger i = [pickerView selectedRowInComponent:0];
	ComicChapter *chapter = [ComicChapter chapterWithLink:[chapterLinkList objectAtIndex:i]];
	[chapter loadPages];
	//[Utils saveDatabase];
	[[self status] setObject:[NSString stringWithFormat:@"⇪"] forKey:[chapter link]];

	[DownloadThread downloadChapterWithID:[chapter objectID]];
	[pickerView reloadAllComponents];
	
}

/*- (void) prefetchChapter {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized (self) {		
		ComicChapter *chapter = [ComicChapter chapterWithLink:[downloadList objectAtIndex:0]];
		
		[chapter loadPages];
		NSArray *pages = [chapter pagesAll];
		
		for (ComicPage *page in pages) {		
			[page fetchImage];
		}
		[[self status] setObject:[NSString stringWithFormat:@"·"] forKey:[chapter link]];
		
		[downloadList removeObjectAtIndex:0];
		
		[pickerView reloadAllComponents];
	}
	[pool release];
}*/

-(IBAction) gotoFirstChapter: (id) sender
{
	[pickerView selectRow:0 inComponent:0 animated:TRUE];
}
-(IBAction) gotoLastChapter: (id) sender
{
	//ComicSeries *comicSeries = (ComicSeries *) [[Utils databaseContext] objectWithID:comicSeriesID];
	[pickerView selectRow:([chapterNameList count]-1) inComponent:0 animated:TRUE];
}
-(IBAction) gotoSelectedChapter: (id) sender
{
	[self gotoChapterWithNr:[pickerView selectedRowInComponent:0]];
}

-(IBAction) goBack: (id) sender
{
	[self dismissModalViewControllerAnimated:TRUE];
	[readComicController setCurrentChapter:0];
}

- (void) gotoChapterWithNr: (NSInteger) i {
	
	ComicSeries *comicSeries = (ComicSeries *) [[Utils databaseContext] objectWithID:comicSeriesID];
	if ([DownloadThread getDownloadStatusForChapterLink:[[comicSeries chapterAtIndex:i] link]] != NONE) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Wait for the download to complete" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
		
		return;
	}
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
		 
	[readComicController setSeriesID:[comicSeries objectID]];
	[readComicController setCurrentChapter:i];
	

	
	[self presentModalViewController:readComicController animated:TRUE];
}

- (void) showFavoriteLabel: (BOOL) b {
	if (b) {
		[favoriteLabel setHidden:FALSE];
	} else {
		[favoriteLabel setHidden:TRUE];
	}
}

- (void) reloadPickerView {
	[pickerView reloadComponent:0];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];

	comicSeriesID = nil;
	chapterLinkList = [[NSMutableArray alloc] init];
	chapterNameList = [[NSMutableArray alloc] init];
	downloadList = [[NSMutableArray alloc] init];
	status = [[NSMutableDictionary alloc] init];
}


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (comicSeriesID == nil)
		[self goBack:self];
	
	ComicSeries *comicSeries = (ComicSeries *) [[Utils databaseContext] objectWithID:comicSeriesID];
	
	if (comicSeries == nil || [comicSeries link] == nil || [comicSeries link] == @"")
		[self goBack:self];
	
	NSArray *comicChapters = [comicSeries chaptersAll];
	
	[self setChapterLinkList:[[NSMutableArray alloc] init]];
	[self setChapterNameList:[[NSMutableArray alloc] init]];
	
	for (ComicChapter *c in comicChapters) {
		NSString *str = [[[c name] copy] autorelease];
		
		
		if ([str length] > 22) {
			
			str =  [str substringFromIndex:([str length]-22)];
			NSRange r = [str rangeOfString:@" "];
			
			if (r.location != NSNotFound) {
				str = [str substringFromIndex:r.location];
			}
			str = [@"… " stringByAppendingString:str];
		}
		
		
		
		[chapterNameList addObject:str];
		
		[chapterLinkList addObject:[c link]];
	}
	
	
	[coverArtButton setBackgroundImage:[UIImage imageWithData:[comicSeries coverArt]] forState:UIControlStateNormal];
	coverArtButton.contentMode = UIViewContentModeScaleToFill;
	
	navigationTitle.title = [comicSeries name];
	artistLabel.text = [comicSeries artist];
	authorLabel.text = [comicSeries author];
	
	lastReleaseLabel.text = [Utils formattedDateRelativeToNow:[comicSeries latestRelease]]; 
	
	[pickerView reloadAllComponents];
	
	NSInteger row = [[comicSeries latestChapterRead] integerValue];
	[pickerView selectRow:row inComponent:0 animated:TRUE];
	
	
	BOOL isFavorite = [[comicSeries favorite] boolValue];
	[self showFavoriteLabel:isFavorite];
	
	for (ComicChapter *c in comicChapters) {
		if ([c isAllImagesDownloaded]) {
			[status setObject:@"·" forKey:[c link]];
		}
	}
}


- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
	
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark picker datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

// this will return the count for my data array for the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [chapterNameList count];
}

#pragma mark -
#pragma mark picker delegate

// This will populate the UIPickerView.  We can use the row and component arguments to sift through our datasource
// and populate the rows and columns (components) with data.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	NSString *downloadstatus = [[self status] objectForKey:[chapterLinkList objectAtIndex:row]];
	NSString *chaptername = [chapterNameList objectAtIndex:row];
	if (downloadstatus != nil) {
		return [NSString stringWithFormat:@"%@ %@", downloadstatus, chaptername];
	} else {
		return chaptername;
	}
}

@end
