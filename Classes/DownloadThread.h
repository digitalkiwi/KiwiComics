//
//  DownloadThread.h
//  KiwiComics
//

// This class is only used when downloading complete manga chapters.
// It is not used for prefetching.



@interface DownloadThread : NSObject {
}

typedef enum downloadStatus
{
	NONE,
	DOWNLOADING,
	INDOWNLOADLIST
} DownloadStatus;

// Download the chapter with ID.
+ (void) downloadChapterWithID: (NSManagedObjectID *) chapterID;

// Get a string which contains the status of the detailed download progress for that manga.
+ (NSString *) getStringForSeriesLink: (NSString *) series;

// Get the status of the chapter downloading.
+ (DownloadStatus) getDownloadStatusForChapterLink: (NSString *) link;

// Starts a thread in the background. Should only be called once, preferably as soon as the app starts.
+ (void) start;

// Should not be called. Is already called by the start function
+ (void) run;

@end
