//
//  TrekListViewController.m
//  RunQuest
//
//  Created by Joe Walsh on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrekListViewController.h"
#import "TrekViewController.h"
#import <CoreData/CoreData.h>

@implementation TrekListViewController

- (id)init {
	if (self = [super initWithNibName:@"TrekListView" bundle:nil]) {
		
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Workouts" 
															  image:[UIImage imageNamed:@"workout_log_tab_icon.png"] 
																tag:0] autorelease];
		[[self navigationItem] setTitle:@"Workout Summary"];
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Summary" style:UIBarButtonItemStyleBordered target:nil action:nil];
		[[self navigationItem] setBackBarButtonItem:newBackButton];
	}
	return self;
}

@synthesize fetchedResultsController;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	_formatter = [[NSDateFormatter alloc] init];
	[_formatter setDateStyle:NSDateFormatterShortStyle];
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
	if ( error )
		NSLog(@"%@", error);  // TODO: care
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[fetchedResultsController.sections objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	@try {
		id object = [fetchedResultsController objectAtIndexPath:indexPath];
		[cell.textLabel setText:[_formatter stringForObjectValue:[object valueForKey:@"date"]]];
	}
	@catch (NSException * e) {
		NSLog(@"%@",e);
		[cell.textLabel setText:@" "];
	}
	@finally {
		
	} 
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	

	TrekViewController *trekViewController = [[TrekViewController alloc] initWithNibName:@"TrekView" bundle:nil];
	//trekViewController.trek = 
	trekViewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	[self.navigationController pushViewController:trekViewController animated:YES];
	[trekViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[_formatter release];
	_formatter = nil;
    [super dealloc];
}


@end

