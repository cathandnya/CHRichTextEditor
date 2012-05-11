//
//  CHRichTextEditorViewController.h
//  CHRichTextEditor
//
//  Created by Naomoto nya on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHSheetColorPickerViewController.h"

@class CHRichTextEditorViewController;

@protocol CHRichTextEditorViewControllerDelegate <NSObject>
- (void) richTextEditor:(CHRichTextEditorViewController *)sender finished:(BOOL)done;
@end

@interface CHRichTextEditorViewController : UIViewController<CHSheetColorPickerViewControllerDelegate> {
	NSTimer *autoScrollTimer;
	BOOL keyboardIsPresent;
	CGPoint scrollOffset;
	CGPoint lastTouchPoint;
	CGFloat htmlHeight;
	CHSheetColorPickerViewController *colorPickerViewController;
}

@property (retain, nonatomic) IBOutlet UITextField *dummyTextField;
@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIToolbar *styleBar;
@property (retain, nonatomic) IBOutlet UIToolbar *sizeBar;
@property (retain, nonatomic) IBOutlet UIToolbar *alignBar;
@property (retain, nonatomic) IBOutlet UIToolbar *colorBar;
@property (retain, nonatomic) IBOutlet UISegmentedControl *colorSegment;

@property(readwrite, nonatomic, retain) NSString *html;
@property(readwrite, nonatomic, assign) id<CHRichTextEditorViewControllerDelegate>delegate;

@end
