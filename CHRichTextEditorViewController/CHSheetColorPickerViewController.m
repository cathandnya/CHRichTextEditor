//
//  CHSheetColorPickerViewController.m
//  CHRichTextEditor
//
//  Created by Naomoto nya on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CHSheetColorPickerViewController.h"
#import "HRColorUtil.h"

@interface CHSheetColorPickerViewController ()

@end

@implementation CHSheetColorPickerViewController

@synthesize keyboardHeight, delegate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		/*
		 float width; // viewの横幅。デフォルトは320.0f;
		 float headerHeight; // 明度スライダーを含むヘッダ部分の高さ(デフォルトは106.0f。70.0fくらいが下限になると思います)
		 float colorMapTileSize; // カラーマップの中のタイルのサイズ。デフォルトは15.0f;
		 int colorMapSizeWidth; // カラーマップの中にいくつのタイルが並ぶか (not view.width)。デフォルトは20;
		 int colorMapSizeHeight; // 同じく縦にいくつ並ぶか。デフォルトは20;
		 float brightnessLowerLimit; // 明度の下限
		 float saturationUpperLimit; // 彩度の上限
		 */
		HRColorPickerStyle style;
		style.width = 320;
		style.headerHeight = 70;
		style.colorMapTileSize = 15;
		style.colorMapSizeWidth = 20;
		style.colorMapSizeHeight = 9;
		style.brightnessLowerLimit = 0.0f;
		style.saturationUpperLimit = 0.95f;
		
		HRRGBColor c = {0, 0, 0};
		colorPickerView = [[HRColorPickerView alloc] initWithStyle:style defaultColor:c];
		colorPickerView.delegate = self;
	}
	return self;
}

- (void) dealloc {
	[colorPickerView release];
	[super dealloc];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:colorPickerView];
}

- (void) hide {
    self.view.frame = CGRectMake([self width], 0, [self width], keyboardHeight);
	colorPickerView.frame = CGRectMake(0, 0, [self width], keyboardHeight);
}

- (void) show {
    self.view.frame = CGRectMake(0, 0, [self width], keyboardHeight);
	colorPickerView.frame = CGRectMake(0, 0, [self width], keyboardHeight);
}

- (BOOL) isPresent {
	return panel && !panel.hidden && self.view.frame.origin.y < keyboardHeight;
}

- (CGFloat) animationDuration {
	return 0.3;
}

- (void)present {
    if (self.isPresent) {
		return;
	}
	
    //[panel release];
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	CGRect r = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - keyboardHeight, [UIScreen mainScreen].bounds.size.width, keyboardHeight);
	if (!panel) {
		panel = [[UIWindow alloc] initWithFrame:r];
		panel.windowLevel = UIWindowLevelStatusBar + 1;
		//panel.windowLevel = UIWindowLevelAlert - 10;
		panel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		//panel.userInteractionEnabled = NO;
		r.origin = CGPointZero;
		self.view.frame = r;
		//[panel setRootViewController:self];
		[panel addSubview:self.view];
		[panel makeKeyAndVisible];
		[keyWindow makeKeyWindow];
	} else {
		panel.frame = r;
		panel.hidden = NO;
	}	
    
	[self hide];
	
	if ([self animationDuration] > 0) {
		[UIView beginAnimations:@"showAnimation" context:nil];
		[UIView setAnimationDuration:[self animationDuration]];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop:finished:context:)];
    }
    [self show];
	if ([self animationDuration] > 0) {
		[UIView commitAnimations];
	}
}

- (void)dismiss
{
    if (!self.isPresent) {
		return;
	}
	
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow makeKeyWindow];
	if ([self animationDuration] > 0) {
		[UIView beginAnimations:@"presentEmojiPanel" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDuration:[self animationDuration]];
	}
	[self hide];
	if ([self animationDuration] > 0) {
		[UIView commitAnimations];
	} else {
		//[panel resignKeyWindow];
		//[panel release];
		//panel = nil;
		panel.hidden = YES;
	}
}

- (void) showAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	panel.hidden = YES;
	//[panel resignKeyWindow];
	//[panel release];
	//panel = nil;
}

#pragma mark-

- (void)colorWasChanged:(HRColorPickerView*)color_picker_view {
	HRRGBColor color = [color_picker_view RGBColor];
	NSString *colorString = [NSString stringWithFormat:@"#%02x%02x%02x", (int)(color.r * 255), (int)(color.g * 255), (int)(color.b * 255)];
	[delegate colorSelected:colorString];
}

@end
