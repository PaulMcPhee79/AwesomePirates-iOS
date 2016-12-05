//
//  BookletSubview.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TitleSubview.h"

#define CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED @"bookletPageTurnedEvent"

@interface BookletSubview : TitleSubview {
	BOOL mLoop;
	BOOL mPageSwipeEnabled;
    BOOL mPageSwipeIgnored;
	NSString *mBookKey;
	int mPageTurns;
	uint mNumPages;
	uint mPageIndex;
	
	TitleSubview *mCover;
	MenuDetailView *mCurrentPage;
	
	double mSwipeTimestamp;
	NSMutableArray *mSwipeLog;
}

@property (nonatomic,assign) BOOL loop;
@property (nonatomic,readonly) NSString *bookKey;
@property (nonatomic,assign) uint pageIndex;
@property (nonatomic,assign) int pageTurns;
@property (nonatomic,assign) uint numPages;
@property (nonatomic,retain) TitleSubview *cover;
@property (nonatomic,retain) MenuDetailView *currentPage;

+ (BookletSubview *)bookletSubviewWithCategory:(int)category key:(NSString *)key;
- (id)initWithCategory:(int)category key:(NSString *)key;
- (void)enablePageSwipe;
- (void)refreshPageNo;
- (void)turnToPage:(uint)page;
- (void)nextPage;
- (void)prevPage;

@end
