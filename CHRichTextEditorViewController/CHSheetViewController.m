//
//  SheetViewController.m
//
//  Created by nya on 10/02/05.
//

#import "CHSheetViewController.h"


@implementation CHSheetViewController

@dynamic isPresent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)dealloc {
	//[self viewDidUnload];
	
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (CGFloat) height {
	//return self.view.frame.size.height;
	return [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat) width {
	return [UIScreen mainScreen].bounds.size.width;
}

#pragma mark-

- (void) hide {
    self.view.frame = CGRectMake(0, [self height], [self width], 0);

    CGRect rect = self.view.frame;
    //    /* 下に下がるパターン */
    //    emojiView.frame = CGRectMake(0, self.view.frame.size.height, CGRectGetWidth(rect), 0);
    self.view.frame = CGRectMake(0, [self height], CGRectGetWidth(rect), 0);
    //
    //    /* 上にあがるパターン */
    //    emojiView.frame = CGRectMake(0, self.view.frame.size.height - 216, CGRectGetWidth(rect), 0);
}

- (void) show {
    self.view.frame = CGRectMake(0, 0, [self width], [self height]);
}

- (CGFloat) animationDuration {
	return 0.3;
}

- (void)present {
    if (self.isPresent) {
		return;
	}

    [self hide];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [panel release];
	CGRect r = CGRectMake(0, CGRectGetHeight(keyWindow.frame) - [self height], [self width], [self height]);
    panel = [[UIWindow alloc] initWithFrame:r];
    panel.windowLevel = UIWindowLevelAlert - 10;
	panel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	r.origin = CGPointZero;
	self.view.frame = r;
    [panel addSubview:self.view];
    [panel makeKeyAndVisible];
    [keyWindow makeKeyWindow];
    
    [UIView beginAnimations:@"presentEmojiPanel" context:nil];
    [UIView setAnimationDuration:[self animationDuration]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    [self show];
    
    [UIView commitAnimations];
}

- (void)dismiss
{
    if (!self.isPresent) {
		return;
	}

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow makeKeyWindow];
    [UIView beginAnimations:@"presentEmojiPanel" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:[self animationDuration]];
    
	[self hide];
    
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    //    keyWindow.windowLevel = UIWindowLevelNormal;
 	[panel resignKeyWindow];
	[panel release];
	panel = nil;
}

- (void) toggle {
    if (!self.isPresent) {
		[self present];
	} else {
		[self dismiss];
	}
}

- (BOOL) isPresent {
	return (self.view.superview != nil);
}

@end
