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
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)initWithHTMLFolder:(NSString *)path;
- (IBAction)doneButtonPressed:(id)sender;

@end


