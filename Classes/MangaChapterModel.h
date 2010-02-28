//
//  MangaChapterModel.h
//  KiwiComics
//
//  Created by Daniel Öberg on 2009-12-25.
//  Copyright 2009 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MangaSeriesModel;

@interface MangaChapterModel : NSObject {
	NSString *name;
	NSString *link;
	ushort number;
	NSDate *date;
	
	NSArray *pages; //Contains NSStrings
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *link;
@property ushort number;
@property(nonatomic, copy) NSDate *date;

-(NSArray *) pages;
-(void) setPages: (NSArray*) p;


- (void) fill;
+ (NSString *) loadChapterUrlWithChapter: (NSString *) url;
@end
