//
//  ComicImageView.h
//

// ComicImageView is used by ReadComicController to make the manga page "tapable".

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol TapDetectingImageViewDelegate;

@interface ComicImageView : UIImageView {
	
	id <TapDetectingImageViewDelegate> delegate;
	
}

@property (nonatomic, assign) id <TapDetectingImageViewDelegate> delegate;

@end

@protocol TapDetectingImageViewDelegate <NSObject>

@optional
- (void)tapDetectingImageView:(ComicImageView *)view gotSingleTapAtWindowPoint:(CGPoint)tapPoint;
- (void)tapDetectingImageView:(ComicImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingImageView:(ComicImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
@end

