//
//  HelpViewController.h
//  RunQuest
//
//  Created by Joe Walsh on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RQViewController.h"

@interface HelpViewController : RQViewController {
	UIWebView *webView;
	NSString *_path;
	
	UIToolbar *toolbar;
	UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
	UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (id)initWithHTMLFolder:(NSString *)path;
- (IBAction)doneButtonPressed:(id)sender;

@end


