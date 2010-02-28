//
//  ReadComicController.m
//  KiwiComics - This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
//

#import "ReadComicController.h"
#import "ComicChapter.h"
#import "ComicSeries.h"
#import "ComicPage.h"
#import "Utils.h"
#import "KiwiComicsAppDelegate.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@implementation ReadComicController
@synthesize seriesID;
@synthesize chapter;
@synthesize pages;
//@synthesize chapter;
@synthesize currentChapter;
@synthesize animate;
@synthesize isZoomedIn;
@synthesize doubleTapToZoom;
@synthesize zoomLevel;
@synthesize currentPage;
@synthesize nrOfPages;
@synthesize nrOfChapters;



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
    // set up main scroll view
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];

	
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setDelegate:self];
    [scrollView setBouncesZoom:YES];
    [[self view] addSubview:scrollView];
    
    // add touch-sensitive image view to the scroll view
    ComicImageView *imageView = [[ComicImageView alloc] initWithImage:[UIImage imageNamed:@"loading.jpg"]];
    [imageView setDelegate:self];
    [imageView setTag:ZOOM_VIEW_TAG];
	[imageView setContentMode:UIViewContentModeTop];
    [scrollView setContentSize:[imageView frame].size];
    [scrollView addSubview:imageView];
	//[imageView setController]
    [imageView release];
	
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [scrollView frame].size.width  / [imageView frame].size.width;
    [scrollView setMinimumZoomScale:minimumScale];
    [scrollView setZoomScale:minimumScale];
	
	currentPage = 0;

	[self setAnimate:[[NSUserDefaults standardUserDefaults] boolForKey:@"AnimationOn"]];
	[self setDoubleTapToZoom:[[NSUserDefaults standardUserDefaults] boolForKey:@"TapToZoom"]];
	[self setZoomLevel:[self zoomLevelFromIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"ZoomLevel"]]];
	
	[self setIsZoomedIn:FALSE];
	
	activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(320.0f / 2 - 12, 480.0f / 2 - 12, 24, 24)];
	activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									  UIViewAutoresizingFlexibleRightMargin |
									  UIViewAutoresizingFlexibleTopMargin |
									  UIViewAutoresizingFlexibleBottomMargin);
	
	[[self view] addSubview:activityWheel];
}

- (CGFloat) zoomLevelFromIndex: (NSInteger) zoomIndex {
	return ((zoomIndex == 0)? 1.0f : ((zoomIndex == 1)? 0.75f : 0.5f));
}


- (IBAction) gotoNextPage
{
	if (currentPage >= (nrOfPages -1)) {
		if (currentChapter >= (nrOfChapters -1)) {
			[self showMenu];
			
			return;
		} else {
			[chapter setLatestPageRead:[NSNumber numberWithInt:0]];
			[chapter release];
			currentChapter += 1;
			[self loadChapter];
		}
	} else {
		currentPage = (currentPage + 1);
	}

	

	[self loadImageWithActivityImg];
}
- (IBAction) gotoPreviousPage
{
	if (currentPage <= 0) {
		if (currentChapter <= 0) {
			[self showMenu];
			
			return;
		} else {
			[chapter release];
			currentChapter -= 1;
			[self loadChapter];
			currentPage = [[chapter pages] count] - 1;
		}
	} else {
		currentPage = (currentPage - 1);
	}
	
	[self loadImageWithActivityImg];
}

- (void) loadChapter {
	ComicSeries *series = ((ComicSeries *) [[Utils databaseContext] objectWithID:seriesID]);
	[self setChapter:[series chapterAtIndex:currentChapter]];
	
	if ([chapter loadPages] == FALSE) {
		[self showMenu];
	}
	self.nrOfPages = [[chapter pages] count];
	currentPage = 0;
	[series setLatestChapterRead:[NSNumber numberWithInteger:currentChapter]];
	
	[self setPages:[chapter pagesAll]];
}

- (IBAction) showMenu
{
	[[UIApplication sharedApplication] setStatusBarHidden: NO animated: YES];
	[self dismissModalViewControllerAnimated:TRUE];
}



- (void)viewDidAppear:(BOOL)animated {
	ComicSeries *series = ((ComicSeries *) [[Utils databaseContext] objectWithID:seriesID]);
	[[[scrollView subviews] objectAtIndex:0] becomeFirstResponder];
	[super viewDidAppear:animated];
	
	[self setAnimate:[[NSUserDefaults standardUserDefaults] boolForKey:@"AnimationOn"]];
	[self setDoubleTapToZoom:[[NSUserDefaults standardUserDefaults] boolForKey:@"TapToZoom"]];
	[self setZoomLevel:[self zoomLevelFromIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"ZoomLevel"]]];
	
	[self setNrOfChapters: [[series chapters] count]];
	
	
	[self loadChapter];
	currentPage = [[[self chapter] latestPageRead] intValue];
	if ([self chapter] == nil) {
		[self showMenu];
		return;
	}

	[self loadImage];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[[scrollView subviews] objectAtIndex:0] resignFirstResponder];
    [super viewWillDisappear:animated];
	
	[self setNrOfChapters:0];
	[self setNrOfPages:0];
	[self setPages:nil];
	[self setSeriesID:nil];
	[self setChapter:nil];
	[self setCurrentPage:0];
	//[self se];
}

- (void) loadImageWithActivityImg {

	[activityWheel startAnimating];
	
	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(loadImage) userInfo:nil repeats:NO];
}


- (void) loadImage {
	@synchronized (self) {
		ComicPage *page = [[self pages] objectAtIndex:currentPage];
		
		NSData *data = [page getImageData];
		if (data == nil) {
			[NSThread sleepForTimeInterval:1.0];

			NSData *data = [page getImageData];
			if (data == nil) {
				[self performSelector:@selector(showMenu) withObject:self afterDelay:2.0];
				return;
			}
		}
		
		
		
		
		if (animate == TRUE) {
			[UIView beginAnimations:@"MoveAndStrech" context:nil];
			[UIView setAnimationDuration:0.75f];
			[UIView setAnimationDelay:0.0f];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationTransition:UIViewAnimationCurveEaseIn forView:scrollView cache:NO];
		}

		[scrollView setZoomScale:1.0f];
		ComicImageView *imageView = [[scrollView subviews] objectAtIndex:0];
		UIImage *img = [[UIImage alloc] initWithData:data];
		[imageView setImage:img];
		
		CGRect rect = CGRectMake(0, 0, img.size.width , img.size.height);
		[scrollView setContentSize:rect.size];
		[imageView setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];

		float minimumScale = [scrollView frame].size.width  / img.size.width;
		[img release];

		
		[scrollView setMinimumZoomScale:minimumScale];
		[scrollView setZoomScale:minimumScale];
		
		[scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, [scrollView frame].size.width, 1.0f) animated:FALSE];
		
		if (animate == TRUE) {
			[UIView commitAnimations];
		}
		
		[[self chapter] setLatestPageRead:[NSNumber numberWithInt:currentPage]];
		[Utils saveDatabase];
		[self performSelectorInBackground:@selector(prefetchImage) withObject:nil]; 
		[self setIsZoomedIn: FALSE];
		[activityWheel stopAnimating];
	}
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

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

- (void) prefetchImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// wait for 3 seconds before starting the thread, you don't have to do that. This is just an example how to stop the NSThread for some time
	
	if (([[self pages] count] - 2) >= [self currentPage]) {
		ComicPage *tmpPage = (ComicPage *) [[Utils databaseContext] objectWithID: [[pages objectAtIndex:(currentPage +1)] objectID]];
		[tmpPage fetchImage];
	}
	
	[pool release];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView2 {
	return [[scrollView2 subviews] objectAtIndex:0];
}

- (void)dealloc {
    [super dealloc];
}
#pragma mark TapDetectingImageViewDelegate methods

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
		[self showMenu];
    }	
}

- (void)tapDetectingImageView:(ComicImageView *)view gotSingleTapAtWindowPoint:(CGPoint)tapPoint {
	if (tapPoint.y < 100.0f) {
		[self gotoPreviousPage];
	} else if (tapPoint.y > 380.0f) {
		[self gotoNextPage];
	}
}

- (void)tapDetectingImageView:(ComicImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
	if (doubleTapToZoom) {
		// double tap zooms in
		float newScale = 1.0f;
		if (isZoomedIn) {
			newScale = [scrollView minimumZoomScale];
		}
		CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
		[scrollView zoomToRect:zoomRect animated:YES];
		isZoomedIn = !isZoomedIn;
	} else {
		[self showMenu];
	}
}

- (void)tapDetectingImageView:(ComicImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
	[self showMenu];
	
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
