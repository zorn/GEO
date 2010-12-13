//
//  HelpViewController.m
//  RunQuest
//
//  Created by Joe Walsh on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import "RQConstants.h"

@implementation HelpViewController

@synthesize webView, backButton, forwardButton, toolbar, activityIndicator;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


- (id)initWithHTMLFolder:(NSString *)path {
	if (( self = [super initWithNibName:@"HelpViewController" bundle:nil] )) {
		_path = [path copy];
	} return self;
}


- (void)loadBase {
	NSString *htmlPath = [_path stringByAppendingPathComponent:@"index.html"];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadBase];
}

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
		NSArray *items = [toolbar items];
		if ( ![items containsObject:backButton] ) {
			NSMutableArray *mutableItems = [items mutableCopy];
			[mutableItems insertObject:backButton atIndex:0];
			[mutableItems insertObject:forwardButton atIndex:1];
			[toolbar setItems:mutableItems animated:YES];
			[mutableItems release];
			[backButton setEnabled:YES];
		}
	}
	
	return YES;
}

- (IBAction)goBack:(id)sender {
	if ( webView.canGoBack ) {
		[webView goBack];
	}
	else {
		[self loadBase];
	}
}
		
- (IBAction)goForward:(id)sender {
	if ( webView.canGoForward ) {
		[webView goForward];
	}
}

- (void)updateNav {	
	forwardButton.enabled = [webView canGoForward];
	backButton.enabled = [webView canGoBack];
}

- (void)webViewDidStartLoad:(UIWebView *)webView_ {
	[self updateNav];
	[activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView_ {
	[self updateNav];
	[activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
	[activityIndicator stopAnimating];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.webView = nil;
	self.backButton = nil;
	self.activityIndicator	 = nil;
	self.toolbar = nil;
	self.forwardButton = nil;
}

- (IBAction)doneButtonPressed:(id)sender {
	[delegate viewControllerDidEnd:self];
}


- (void)dealloc {
	[_path release];
	[webView release];
	[backButton release];
	[forwardButton release];
	[toolbar release];
	[activityIndicator release];
    [super dealloc];
}


@end
