//
//  CHSheetColorPickerViewController.h
//  CHRichTextEditor
//
//  Created by Naomoto nya on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHSheetViewController.h"
#import "HRColorPickerView.h"

@class HRColorPickerView;

@protocol CHSheetColorPickerViewControllerDelegate <NSObject>
- (void) colorSelected:(NSString *)colorString;
@end

@interface CHSheetColorPickerViewController : CHSheetViewController<HRColorPickerViewDelegate> {
	HRColorPickerView *colorPickerView;
}

@property(readwrite, nonatomic, assign) CGFloat keyboardHeight;
@property(readwrite, nonatomic, assign) id<CHSheetColorPickerViewControllerDelegate> delegate;

@end
