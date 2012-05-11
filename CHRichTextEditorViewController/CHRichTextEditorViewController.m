//
//  CHRichTextEditorViewController.m
//  CHRichTextEditor
//
//  Created by Naomoto nya on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CHRichTextEditorViewController.h"

#ifdef DEBUG
#define DLog(...)	NSLog(__VA_ARGS__)
#else 
#define DLog(...)
#endif

@interface CHRichTextEditorViewController ()

@end

@implementation CHRichTextEditorViewController

@synthesize dummyTextField;
@synthesize baseView;
@synthesize webView;
@synthesize colorSegment;
@synthesize html;
@synthesize toolbar, styleBar, sizeBar, alignBar, colorBar;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		colorPickerViewController = [[CHSheetColorPickerViewController alloc] initWithNibName:@"CHSheetColorPickerViewController" bundle:nil];
		colorPickerViewController.delegate = self;
    }
    return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[html release];
	[dummyTextField release];
	[baseView release];
	[webView release];
	[toolbar release];
	[styleBar release];
	[sizeBar release];
	[alignBar release];
	[colorBar release];
	[colorPickerViewController release];
	[colorSegment release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"RichTextEditor", nil);
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];

	NSBundle *bundle = [NSBundle mainBundle];
    NSURL *indexFileURL = [bundle URLForResource:@"CHRichTextEditor" withExtension:@"html"];
	NSString *text = [NSString stringWithContentsOfURL:indexFileURL encoding:NSUTF8StringEncoding error:nil];
	NSString *body = self.html;
	if (body.length == 0) {
		body = @"";
	} else {
	}
	text = [text stringByReplacingOccurrencesOfString:@"{%content}" withString:body];
	[webView loadHTMLString:text baseURL:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self setDummyTextField:nil];
	[self setBaseView:nil];
	[self setWebView:nil];
	[self setToolbar:nil];
	[self setSizeBar:nil];
	[self setAlignBar:nil];
	[self setColorBar:nil];
	
	[self setColorSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-

- (void) autoScrollTimerAction {
	NSInteger height = 0;
	height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').offsetHeight;"] intValue];
	if (htmlHeight == 0) {
		htmlHeight = height;
	} else if (htmlHeight != height) {
		CGPoint loc = self.webView.scrollView.contentOffset;
		loc.y += (height - htmlHeight);
		CGRect r = CGRectMake(0, loc.y, 1, self.webView.frame.size.height);
		if (CGRectGetMaxY(r) > self.webView.scrollView.contentSize.height - 8) {
			r.size.height -= CGRectGetMaxY(r) - self.webView.scrollView.contentSize.height + 8;
		}
		[self.webView.scrollView scrollRectToVisible:r animated:YES];
		//self.webView.scrollView.contentOffset = loc;
		htmlHeight = height;
	}
	
	/*
	 NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"];
	 if (![prevStringForScroll isEqualToString:str]) {
	 DLog(@"autoScrollTimerAction %@", prevStringForScroll);
	 DLog(@" -> %@", str);
	 
	 NSInteger height = 0;
	 if (prevStringForScroll.length < str.length && [[str substringFromIndex:prevStringForScroll.length] hasSuffix:@"<div><br></div>"]) {
	 // 末尾に改行が追加された
	 height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').offsetHeight;"] intValue];
	 } else if (str.length < prevStringForScroll.length && [[prevStringForScroll substringFromIndex:str.length] hasSuffix:@"<div><br></div>"]) {
	 // 末尾の改行が削除された
	 height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').offsetHeight;"] intValue];
	 } else {
	 // キャレット位置にダミーを入れる
	 //[webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('insertHTML', false, '<div id=\"scrollPosition\"></div>')"];
	 DLog(@"%@", [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"]);
	 
	 // offset取得
	 height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('scrollPosition').offsetTop;"] intValue];
	 
	 // ダミー削除
	 [webView stringByEvaluatingJavaScriptFromString:@"var i=document.getElementById('scrollPosition'); i.parentNode.removeChild(i);"];
	 DLog(@"%@", [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"]);
	 }		
	 self.prevStringForScroll = str;
	 
	 // スクロール
	 //[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %d);", height]];   
	 [webView.scrollView scrollRectToVisible:CGRectMake(0, height, 1, 40) animated:YES];
	 }	
	 */
}

- (void) scrollToCalet {
	DLog(@"scrollToCalet");
	NSInteger height = 0;
	
	DLog(@"selectionStart: %@", [self.webView stringByEvaluatingJavaScriptFromString:@"document.getSelection().toString();"]);
	DLog(@"%@", [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"]);
	/*
	 NSString *b = [webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('insertHTML');"];
	 DLog(@"queryCommandEnabled: %@", b);
	 if (![b isEqualToString:@"true"]) {
	 return;
	 }
	 */
	// キャレット位置にダミーを入れる
	//[webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('insertHTML', false, '<a id=\"scrollPosition\"><a>')"];
	//[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('insertHTML', false, '<img src=\"%@\" id=\"scrollPosition\">')", [[NSBundle mainBundle] URLForResource:@"calet_dummy" withExtension:@"png"]]];
	[webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('insertHTML', false, '<div id=\"scrollPosition\"></div>')"];
	DLog(@"%@", [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"]);
	
	// offset取得
	height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('scrollPosition').offsetTop;"] intValue];
	DLog(@"height: %d", height);
	
	// ダミー削除
	[webView stringByEvaluatingJavaScriptFromString:@"var i=document.getElementById('scrollPosition'); i.parentNode.removeChild(i);"];
	DLog(@"%@", [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"]);
	
	// スクロール
	//[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %d);", height]];   
	CGRect r = CGRectMake(0, height, 1, 40);
	DLog(@"r: %@", NSStringFromCGRect(r));
	DLog(@"contentSize: %@", NSStringFromCGSize(self.webView.scrollView.contentSize));
	if (CGRectGetMaxY(r) > self.webView.scrollView.contentSize.height - 8) {
		r.size.height -= CGRectGetMaxY(r) - self.webView.scrollView.contentSize.height + 8;
	}
	[webView.scrollView scrollRectToVisible:r animated:YES];
	
	//[webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:@"document.getElementById('entryContents').focus();" afterDelay:0.5];
	[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').focus();"];
}

- (void) scrollToPoint:(CGPoint)loc {
	//[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %d);", (int)loc.y]];   
	//webView.scrollView.contentSize = CGSizeMake(webView.scrollView.contentSize.width, webView.scrollView.contentSize.height - 242);
	
	CGRect r = CGRectMake(0, loc.y - 200, 320, self.webView.frame.size.height / 2);
	DLog(@"r: %@", NSStringFromCGRect(r));
	DLog(@"self.webView.frame: %@", NSStringFromCGRect(self.webView.frame));
	DLog(@"contentSize: %@", NSStringFromCGSize(self.webView.scrollView.contentSize));
	r = CGRectIntersection(r, CGRectMake(0, 0, webView.scrollView.contentSize.width, webView.scrollView.contentSize.height - 250));
	if (CGRectGetMaxY(r) > self.webView.scrollView.contentSize.height - 8) {
		//r.size.height -= CGRectGetMaxY(r) - self.webView.scrollView.contentSize.height - 200 + 8;
	}
	[webView.scrollView scrollRectToVisible:r animated:NO];
}

- (void) updateBaseFrame:(CGFloat)keyboardHeight animated:(NSTimeInterval)ti {
	CGRect newFrame = self.view.frame;
	newFrame.origin = CGPointZero;
	newFrame.size.height -= keyboardHeight;//CGRectIntersection(newFrame, keyboardFrameEnd).size.height;
	if (keyboardHeight == 0) {
		newFrame.size.height += 44;
	}
	DLog(@"newFrame: %@", NSStringFromCGRect(newFrame));
	
	if (ti > 0) {
		UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut;
		[UIView animateWithDuration:ti delay:0.0 options:opt animations:^{
			self.baseView.frame = newFrame;
		} completion:^(BOOL finished) {			
		}];
	} else {
		self.baseView.frame = newFrame;
	}
}

static CGFloat accessoryHeight = 0;

- (void)removeBar:(NSDictionary *)dic {	
    // Locate non-UIWindow.
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIWebFormView.
	CGRect r = CGRectZero;
    for (UIView *possibleFormView in [keyboardWindow subviews]) {       
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            for (UIView *subviewWhichIsPossibleFormView in [possibleFormView subviews]) {
                if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
					DLog(@"%@", [subviewWhichIsPossibleFormView description]);
					r = subviewWhichIsPossibleFormView.frame;
					//subviewWhichIsPossibleFormView.hidden = YES;
					//subviewWhichIsPossibleFormView.userInteractionEnabled = NO;
                    [subviewWhichIsPossibleFormView removeFromSuperview];
					DLog(@"remove web form accessory");
                }
            }
        }
    }
	
	if (!CGRectEqualToRect(CGRectZero, r)) {
		//CGRect keyboardFrameEnd = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		//keyboardFrameEnd.size.height -= r.size.height;
		//keyboardFrameEnd.origin.y += r.size.height;
		//NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
		//[mdic setObject:[NSValue valueWithCGRect:keyboardFrameEnd] forKey:UIKeyboardFrameEndUserInfoKey];
		accessoryHeight = r.size.height;
		
		CGRect keyboardFrameEnd = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		//keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:((AppDelegate *)[UIApplication sharedApplication].delegate).window];
		DLog(@"removeBar: %@", NSStringFromCGRect(keyboardFrameEnd));
		[self updateBaseFrame:keyboardFrameEnd.size.height - r.size.height animated:0];
	} else {
		//CGRect keyboardFrameEnd = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		//keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:((AppDelegate *)[UIApplication sharedApplication].delegate).window];
		//[self updateBaseFrame:keyboardFrameEnd.size.height animated:0];
	}
}

- (UIWindow *) keyboardWindow {
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
			return testWindow;
        }
    }
	return nil;
}

#pragma mark-

- (void) keyboardWillShow:(NSNotification *)notif {
	DLog(@"keyboardWillShow");
	if (keyboardIsPresent) {
		DLog(@"%f", [[UIDevice currentDevice].systemVersion floatValue]);
		[self performSelector:@selector(keyboardWillChangeFrameDelay:) withObject:[notif userInfo] afterDelay:0.0];
	} else {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		CGRect keyboardFrameEnd = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		//keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:((AppDelegate *)[UIApplication sharedApplication].delegate).window];
		DLog(@"keyboardWillShow: %@", NSStringFromCGRect(keyboardFrameEnd));
		//CGRect keyboardFrameEnd = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		//[self updateBaseFrame:keyboardFrameEnd.size.height animated:0.3];
		if (keyboardFrameEnd.size.width <= 320) {
			[self performSelector:@selector(removeBar:) withObject:[notif userInfo] afterDelay:0.0];
		}
	}	
}

- (void) keyboardWillHide:(NSNotification *)notif {
	DLog(@"keyboardWillHide");
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(keyboardDidShowDelay) object:nil];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self updateBaseFrame:0 animated:0.3];
	
	NSString *innerHTML = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entryContents').innerHTML"];
	NSLog(@"%@", innerHTML);
	self.html = innerHTML;
	
	keyboardIsPresent = NO;
}

- (void) keyboardWillChangeFrameDelay:(NSDictionary *)dic {
	DLog(@"keyboardWillChangeFrameDelay");
	if (keyboardIsPresent) {
		CGRect keyboardFrameEnd = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		DLog(@"keyboardWillChangeFrameDelay: %@", NSStringFromCGRect(keyboardFrameEnd));
		//keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:((AppDelegate *)[UIApplication sharedApplication].delegate).window];
		[self updateBaseFrame:keyboardFrameEnd.size.height - accessoryHeight animated:0];
	}
}

- (void) keyboardDidShow:(NSNotification *)notif {
	DLog(@"keyboardDidShow");
	keyboardIsPresent = YES;
	
	[self scrollToPoint:lastTouchPoint];
	[self performSelector:@selector(keyboardDidShowDelay) withObject:nil afterDelay:0.1];

	self.toolbar.hidden = NO;
}

- (void) keyboardDidShowDelay {
	DLog(@"keyboardDidShowDelay");
	//[self scrollToCalet];
	//[self scrollToPoint:lastTouchPoint];
	
	htmlHeight = 0;
	[autoScrollTimer invalidate];
	autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(autoScrollTimerAction) userInfo:nil repeats:YES];
}

- (void) keyboardDidHide:(NSNotification *)notif {
	DLog(@"keyboardDidHide");
	[autoScrollTimer invalidate];
	autoScrollTimer = nil;
	
	keyboardIsPresent = NO;
	self.toolbar.hidden = YES;
}

#pragma mark-

- (BOOL) webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *str = [[request URL] absoluteString];
	DLog(@"webview: %@", str);
	
	if ([[[request URL] scheme] isEqualToString:@"chrichtexteditor"]) {
		NSString *path = [[[request URL] absoluteString] substringFromIndex:[@"chrichtexteditor://" length]];
		NSArray *comp = [path componentsSeparatedByString:@"?"];
		if (comp.count > 0) {
			NSString *method = [comp objectAtIndex:0];
			NSArray *params;
			if (comp.count > 1) {
				params = [[comp objectAtIndex:1] componentsSeparatedByString:@"&"];
			} else {
				params = [NSArray array];
			}
			DLog(@"call: %@ %@", method, [params description]);
			if ([method isEqualToString:@"touch"] && params.count == 2) {
				int x = [[params objectAtIndex:0] intValue];
				int y = [[params objectAtIndex:1] intValue];
				
				//y += webView.scrollView.contentOffset.y;
				lastTouchPoint = CGPointMake(x, y);
			}
		}
		return NO;
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)w
{
	DLog(@"webViewDidFinishLoad");
	
	if (scrollOffset.y > 0 && scrollOffset.x == 0) {
		CGFloat h = scrollOffset.y;
		if (scrollOffset.y + webView.frame.size.height > self.webView.scrollView.contentSize.height - 8) {
			h -= scrollOffset.y + webView.frame.size.height - self.webView.scrollView.contentSize.height + 8;
		}
		webView.scrollView.contentOffset = CGPointMake(0, h);
	}
	scrollOffset = CGPointZero;
}

#pragma mark-

- (UIToolbar *) toolbarWithTag:(int)tag {
	switch (tag) {
		case 0:
			return styleBar;
		case 1:
			return sizeBar;
		case 2:
			return alignBar;
		case 3:
			return colorBar;
		default:
			return nil;
	}
}

- (void) showTool:(int)tag animated:(BOOL)b {
	UIToolbar *tool = [self toolbarWithTag:tag];
	if (tool.superview) {
		return;
	}
	
	if (b) {
		tool.frame = CGRectMake(CGRectGetMaxX(toolbar.frame), toolbar.frame.origin.y, self.baseView.frame.size.width, tool.frame.size.height);
		[self.baseView addSubview:tool];
		
		[UIView animateWithDuration:0.3 animations:^{			
			CGRect r = toolbar.frame;
			tool.frame = r;
			
			r.origin.x -= r.size.width;
			toolbar.frame = r;
		} completion:^(BOOL finished) {
			[toolbar removeFromSuperview];
		}];
	} else {
		tool.frame = toolbar.frame;
		[toolbar removeFromSuperview];
		[self.baseView addSubview:tool];
	}
	
	if (tag == 3) {
		colorPickerViewController.keyboardHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.baseView.frame);
		[colorPickerViewController present];
	}
}

- (void) hideTool:(int)tag animated:(BOOL)b {
	UIToolbar *tool = [self toolbarWithTag:tag];
	if (tool.superview == nil) {
		return;
	}
	
	if (b) {
		toolbar.frame = CGRectMake(-CGRectGetWidth(toolbar.frame), toolbar.frame.origin.y, self.baseView.frame.size.width, tool.frame.size.height);
		[self.baseView addSubview:toolbar];
		
		[UIView animateWithDuration:0.3 animations:^{			
			CGRect r = tool.frame;
			toolbar.frame = r;
			
			r.origin.x += r.size.width;
			tool.frame = r;
		} completion:^(BOOL finished) {
			[tool removeFromSuperview];
		}];
	} else {
		toolbar.frame = tool.frame;
		[tool removeFromSuperview];
		[self.baseView addSubview:toolbar];
	}

	if (tag == 3) {
		[colorPickerViewController dismiss];
	}
}

#pragma mark-

- (void) cancelAction:(id)sender {
	[autoScrollTimer invalidate];
	autoScrollTimer = nil;
	
	[delegate richTextEditor:self finished:NO];
}

- (void) doneAction:(id)sender {
	[autoScrollTimer invalidate];
	autoScrollTimer = nil;
	
	[delegate richTextEditor:self finished:YES];
}

- (IBAction)toolbarAction:(UIButton *)sender {
	[self showTool:sender.tag animated:YES];
}

- (IBAction)backAction:(UIButton *)sender {
	[self hideTool:sender.tag animated:YES];
}

- (IBAction)toolDoneAction:(id)sender {
	[dummyTextField becomeFirstResponder];
	[dummyTextField resignFirstResponder];
}

#pragma mark-

- (IBAction)boldAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

- (IBAction)italicAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

- (IBAction)underlineAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"underline\")"];
}

- (IBAction)strikeAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"strikeThrough\")"];
}

- (IBAction)sizeAction:(UIButton *)sender {
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%d')", sender.tag]];
}

- (IBAction)alignLeftAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"justifyLeft\")"];
}

- (IBAction)alignCenterAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"justifyCenter\")"];
}

- (IBAction)alignRightAction:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"justifyRight\")"];
}

- (IBAction)colorSegmentAction:(id)sender {
}

- (void) colorSelected:(NSString *)colorString {
	if (colorSegment.selectedSegmentIndex == 0) {
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", colorString]];
	} else {
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('backColor', false, '%@')", colorString]];
	}
}

@end
