//
//  SampleViewController.m
//  CHRichTextEditor
//
//  Created by Naomoto nya on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController ()

@end

@implementation SampleViewController

@synthesize textView;
@synthesize text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.textView.text = self.text;
}

- (void)viewDidUnload
{
	[self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[textView release];
	[text release];
	[super dealloc];
}

- (IBAction)editAction:(id)sender {
	CHRichTextEditorViewController *vc = [[[CHRichTextEditorViewController alloc] initWithNibName:@"CHRichTextEditorViewController" bundle:nil] autorelease];
	vc.delegate = self;
	vc.html = text;
	
	UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	[self presentModalViewController:nc animated:YES];
}

#pragma mark-

- (void) richTextEditor:(CHRichTextEditorViewController *)sender finished:(BOOL)done {
	if (done) {
		self.text = sender.html;
		self.textView.text = text;
	}
	
	[sender dismissModalViewControllerAnimated:YES];
}

@end
