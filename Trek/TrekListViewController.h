//
//  TrekListViewController.h
//  RunQuest
//
//  Created by Joe Walsh on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NSFetchedResultsController;

@interface TrekListViewController : UITableViewController {
	NSDateFormatter *_formatter;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
