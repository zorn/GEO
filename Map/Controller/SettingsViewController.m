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
	[pauseIPodSwitch release]; pauseIPodSwitch = nil;
	[backgroundMusicVolumeSlider release]; backgroundMusicVolumeSlider = nil;
	[effectSoundVolumeSlider release]; effectSoundVolumeSlider = nil;
	[super dealloc];
}

@synthesize delegate;

@synthesize pauseIPodSwitch;
@synthesize backgroundMusicVolumeSlider;
@synthesize effectSoundVolumeSlider;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.view setFrame:CGRectMake(0,0,320,480)];
	
	// update the view to honor the current defaults
	self.pauseIPodSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundMuteIPod"] boolValue];
	[self.backgroundMusicVolumeSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundVolumeMusic"] floatValue] animated:NO];
	[self.effectSoundVolumeSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundVolumeEffects"] floatValue] animated:NO];
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
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[(AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate] updateAudioSystemVolumeSettings];
}

- (IBAction)playSampleSoundEffect
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"Laser.caf"];
}

@end
