//
//  SettingsController.m
//


#import "SettingsController.h"
#import "ComicListItem.h"
#import "SearchController.h"
#import "ComicSeries.h"

@implementation SettingsController

- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[animationSwitch setOn:[prefs boolForKey:@"AnimationOn"]];
	[doubleTapToZoom setOn:[prefs boolForKey:@"TapToZoom"]];
	[zoomLevel setSelectedSegmentIndex:[prefs integerForKey:@"ZoomLevel"]];
}

-(IBAction) toggleAnimations: (id) sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:[animationSwitch isOn] forKey:@"AnimationOn"];
	[prefs synchronize];
}

-(IBAction) toggleZoomLevel: (id) sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setInteger:[zoomLevel selectedSegmentIndex] forKey:@"ZoomLevel"];
	[prefs synchronize];
}
-(IBAction) toggleDoubleTap: (id) sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:[doubleTapToZoom isOn] forKey:@"TapToZoom"];
	[prefs synchronize];
}
-(IBAction) refreshMangaList: (id) sender {
	[ComicListItem dowloadFromInternetIntoDB];
}

-(IBAction) emptyCache: (id) sender {
	[ComicSeries clearOfflineData];
}

@end
