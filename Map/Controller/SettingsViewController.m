#import "SettingsViewController.h"
#import "AppDelegate_iPhone.h"
#import "SimpleAudioEngine.h"

@implementation SettingsViewController

- (id)init
{
	if (self = [super initWithNibName:@"SettingsView" bundle:nil]) {
		
	}
	return self;
}

- (void)dealloc {
	[tableView release]; tableView = nil;
	[pauseIPodSwitch release]; pauseIPodSwitch = nil;
	[backgroundMusicVolumeSlider release]; backgroundMusicVolumeSlider = nil;
	[effectSoundVolumeSlider release]; effectSoundVolumeSlider = nil;
	
	[iPodSettingTableViewCell release]; iPodSettingTableViewCell = nil;
	[musicSettingTableViewCell release]; musicSettingTableViewCell = nil;
	[effectSoundSettingTableViewCell release]; effectSoundSettingTableViewCell = nil;
	
	[distanceSegmentControl release]; distanceSegmentControl = nil;
	[distanceTableViewCell release]; distanceTableViewCell = nil;
	
	[weightSegmentControl release]; weightSegmentControl = nil;
	[weightTableViewCell release]; weightTableViewCell = nil;
	
	[super dealloc];
}

@synthesize delegate;

@synthesize tableView;
@synthesize pauseIPodSwitch;
@synthesize backgroundMusicVolumeSlider;
@synthesize effectSoundVolumeSlider;

@synthesize iPodSettingTableViewCell;
@synthesize musicSettingTableViewCell;
@synthesize effectSoundSettingTableViewCell;
@synthesize emailFeedbackCell;

@synthesize distanceSegmentControl;
@synthesize distanceTableViewCell;

@synthesize weightSegmentControl;
@synthesize weightTableViewCell;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.view setFrame:CGRectMake(0,0,320,480)];
	
	[self.tableView setSeparatorColor:[UIColor colorWithRed:0.204 green:0.212 blue:0.222 alpha:1.000]]; 
	// YOU MUST DO THIS IN CODE, TRYING TO DO THIS IN IB VIA COLOR PICKER WILL RESULT IN BLACK CORNERS AROUND THE GROUPS
	self.tableView.backgroundColor = [UIColor clearColor];
	
	// update the view to honor the current defaults
	self.pauseIPodSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundMuteIPod"] boolValue];
	[self.backgroundMusicVolumeSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundVolumeMusic"] floatValue] animated:NO];
	[self.effectSoundVolumeSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundVolumeEffects"] floatValue] animated:NO];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayDistanceAsMeters"] boolValue]) {
		self.distanceSegmentControl.selectedSegmentIndex = 1;
	} else {
		self.distanceSegmentControl.selectedSegmentIndex = 0;
	}
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayWeightAsGrams"] boolValue]) {
		self.weightSegmentControl.selectedSegmentIndex = 1;
	} else {
		self.weightSegmentControl.selectedSegmentIndex = 0;
	}
	
	// Can't make segment controls shorter in IB, need to do it in code. :(
	CGRect newFrame;
	newFrame = self.distanceSegmentControl.frame;
	newFrame.size.height = 27.0;
	self.distanceSegmentControl.frame = newFrame;
	newFrame = self.weightSegmentControl.frame;
	newFrame.size.height = 27.0;
	self.weightSegmentControl.frame = newFrame;
	
}

- (IBAction)doneButtonAction:(id)sender
{
	[self updateDefautsBasedOnUI];
	
	[delegate settingsViewControllerDidEnd:self];
}

- (IBAction)updateDefautsBasedOnUI
{
	// take the values of the UI and store them in the defaults
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.pauseIPodSwitch.on] forKey:@"RQSoundMuteIPod"];
	float backgroundMusic = [self.backgroundMusicVolumeSlider value];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:backgroundMusic] forKey:@"RQSoundVolumeMusic"];
	float soundEffects = [self.effectSoundVolumeSlider value];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:soundEffects] forKey:@"RQSoundVolumeEffects"];
	
	
	if (self.distanceSegmentControl.selectedSegmentIndex == 1) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"RQDisplayDistanceAsMeters"];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"RQDisplayDistanceAsMeters"];
	}
	if (self.weightSegmentControl.selectedSegmentIndex == 1) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"RQDisplayWeightAsGrams"];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"RQDisplayWeightAsGrams"];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	[(AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate] updateAudioSystemVolumeSettings];
}

- (IBAction)playSampleSoundEffect
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"Laser.caf"];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"iPod Player";
	} else if (section == 1) {
		return @"Music Volume";
	} else if (section == 2) {
		return @"Sound Effect Volume";
	} else if ( section == 3 ) {
		return NSLocalizedString(@"Feedback", @"Feedback");
	} else if ( section == 4 ) {
		return NSLocalizedString(@"Measurements", @"Measurements");
	}else {
		return @"Unknown Title";
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 4) {
		return 2; // Measurements has two rows
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	if (indexPath.section == 0) {
		cell = self.iPodSettingTableViewCell;
	} else if (indexPath.section == 1) {
		cell = self.musicSettingTableViewCell;
	} else if (indexPath.section == 2) {
		cell = self.effectSoundSettingTableViewCell;
	} else if (indexPath.section == 3 ) {
		cell = self.emailFeedbackCell;
	} else if (indexPath.section == 4 ) {
		if (indexPath.row == 0) {
			 cell = self.distanceTableViewCell;
		} else {
			cell = self.weightTableViewCell;
		}
	}

	cell.backgroundColor = [UIColor colorWithRed:0.060 green:0.069 blue:0.079 alpha:1.000];
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( indexPath.section == 3 )
		return indexPath;
	else
		return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if ( indexPath.section == 3 )
		[self showContactUsMail:self];
}
	

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
	UIView *containerView =	[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 35)] autorelease];
    //containerView.backgroundColor = [UIColor orangeColor];
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 10, 300, 20)] autorelease];
    headerLabel.text = [self tableView:aTableView titleForHeaderInSection:section];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
	return containerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 35;
}


- (IBAction)showContactUsMail:(id)sender{
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] initWithRootViewController:nil];
	[mailViewController setToRecipients:[NSArray arrayWithObject:@"throw_mail@shipitsociety.com"]];
	[mailViewController setSubject:NSLocalizedString(@"GEO Feedback", @"Subject for the feedback e-mail")];
	[mailViewController setMessageBody:NSLocalizedString(@"Let us know what you think!  Be honest, we can handle it.", @"Instructions for the feedback e-mail.") isHTML:NO];
	mailViewController.mailComposeDelegate = self;
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
	
}

#pragma mark Mail View Controller Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	NSUInteger indexes[2];
	indexes[0] = 3;
	indexes[1] = 0;
	[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2] animated:YES];
	[self dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultFailed) {
		UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"E-mail Error" message: @"Unable to send mail.  Check your account settings" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[someError show];
		[someError release];
	}
}


@end
