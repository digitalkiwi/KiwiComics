//
//  MangaSeriesModel.h
//  KiwiComics
//
//  Created by Daniel Öberg on 2009-12-25.
//  Copyright 2009 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MangaSeriesModel : NSObject {
	NSString *name;
	NSString *link;
	NSString *author;
	NSString *artist;
	NSString *description;
	
	NSData  *coverArt;
	NSArray  *chapters; //Contains MangaChapterModel
	NSDate *latestRelease;
}

- (id) initWithName: (NSString *) comicname sublink: (NSString *) link;
+ (NSArray *)loadAllMangaNames;
- (void)fill;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *link;
@property(nonatomic, copy) NSString *author;
@property(nonatomic, copy) NSString *artist;
@property(nonatomic, copy) NSString *description;

@property(nonatomic, retain) NSData *coverArt;
@property(nonatomic, retain) NSArray  *chapters;
@property(nonatomic, copy) NSDate  *latestRelease;

@end
