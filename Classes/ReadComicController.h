//
//  ReadComicController.h
//  KiwiComics
//

// ReadComicController is the Controller for the ReadComic view which displays manga pages and lets you tap on
// the sides to switch between previous and the next image.

#import <UIKit/UIKit.h>
#import "ComicImageView.h"
@class ComicSeries;
@class ComicChapter;
@class ComicPage;

@interface ReadComicController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {
	NSManagedObjectID *seriesID;
	ComicChapter *chapter;
	NSArray *pages;
	
	NSInteger currentChapter;
	NSInteger currentPage;
	Boolean animate;
	Boolean doubleTapToZoom;
	Boolean isZoomedIn;
	CGFloat zoomLevel;
	
	NSInteger nrOfChapters;
	NSInteger nrOfPages;
	
	UIScrollView *scrollView;
	
	UIActivityIndicatorView *activityWheel;
}

@property(nonatomic, retain) NSManagedObjectID *seriesID;
@property(nonatomic, retain) ComicChapter *chapter;
@property(retain) NSArray *pages;
@property Boolean animate;

@property NSInteger currentPage;
@property(nonatomic) NSInteger currentChapter;
@property Boolean isZoomedIn;
@property Boolean doubleTapToZoom;
@property CGFloat zoomLevel;
@property NSInteger nrOfChapters;
@property NSInteger nrOfPages;


- (void) prefetchImage;
- (void) loadImage;
- (IBAction) gotoNextPage;
- (IBAction) gotoPreviousPage;
- (IBAction) showMenu;

- (void) loadChapter;

- (void) loadImageWithActivityImg;


- (CGFloat) zoomLevelFromIndex: (NSInteger) zoomIndex;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end
